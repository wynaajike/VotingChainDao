;; VotingChainDAO - A decentralized governance contract
;; Allows token holders to create and vote on proposals

;; Constants
(define-constant ERR-NOT-TOKEN-OWNER (err u1))
(define-constant ERR-INVALID-PROPOSAL (err u2))
(define-constant ERR-DUPLICATE-PROPOSAL (err u3))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u4))
(define-constant ERR-ALREADY-VOTED (err u5))
(define-constant ERR-INSUFFICIENT-TOKENS (err u6))
(define-constant ERR-VOTING-CLOSED (err u7))
(define-constant ERR-QUORUM-NOT-MET (err u8))
(define-constant ERR-UNAUTHORIZED (err u9))

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var proposal-count uint u0)
(define-data-var min-tokens-to-propose uint u100)
(define-data-var quorum-percentage uint u51)
(define-data-var voting-period uint u144) ;; ~24 hours in blocks
(define-data-var total-tokens uint u0)    ;; Track total tokens in circulation

;; Data maps
(define-map proposals
    uint
    {
        title: (string-ascii 50),
        description: (string-ascii 500),
        proposer: principal,
        start-block: uint,
        yes-votes: uint,
        no-votes: uint,
        executed: bool
    }
)

(define-map votes
    {proposal-id: uint, voter: principal}
    {voted: bool, vote: bool}
)

(define-map token-balances principal uint)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-token-balance (address principal))
    (default-to u0 (map-get? token-balances address))
)

(define-read-only (get-total-tokens)
    (var-get total-tokens)
)

(define-read-only (get-contract-owner)
    (var-get contract-owner)
)

(define-read-only (is-voting-open (proposal-id uint))
    (let (
        (proposal (unwrap! (get-proposal proposal-id) false))
        (current-block block-height)
    )
    (<= current-block (+ (get start-block proposal) (var-get voting-period)))
    )
)

;; Private functions
(define-private (check-proposal-validity (title (string-ascii 50)) (description (string-ascii 500)))
    (let (
        (caller tx-sender)
        (token-balance (get-token-balance caller))
    )
    (asserts! (>= token-balance (var-get min-tokens-to-propose))
        ERR-INSUFFICIENT-TOKENS)
    (asserts! (> (len title) u0) ERR-INVALID-PROPOSAL)
    (asserts! (> (len description) u0) ERR-INVALID-PROPOSAL)
    (ok true))
)

;; Public functions
(define-public (create-proposal (title (string-ascii 50)) (description (string-ascii 500)))
    (let (
        (proposal-id (+ (var-get proposal-count) u1))
        (caller tx-sender)
    )
        ;; Validate proposal
        (try! (check-proposal-validity title description))
        
        ;; Create new proposal
        (map-set proposals proposal-id
            {
                title: title,
                description: description,
                proposer: caller,
                start-block: block-height,
                yes-votes: u0,
                no-votes: u0,
                executed: false
            }
        )
        
        ;; Increment proposal count
        (var-set proposal-count proposal-id)
        (ok proposal-id)
    )
)

(define-public (vote (proposal-id uint) (vote-for bool))
    (let (
        (caller tx-sender)
        (token-balance (get-token-balance caller))
        (proposal (unwrap! (get-proposal proposal-id) ERR-PROPOSAL-NOT-FOUND))
        (previous-vote (get-vote proposal-id caller))
    )
        ;; Validate voting conditions
        (asserts! (> token-balance u0) ERR-INSUFFICIENT-TOKENS)
        (asserts! (is-voting-open proposal-id) ERR-VOTING-CLOSED)
        (asserts! (is-none previous-vote) ERR-ALREADY-VOTED)
        
        ;; Record vote
        (map-set votes
            {proposal-id: proposal-id, voter: caller}
            {voted: true, vote: vote-for}
        )
        
        ;; Update vote counts
        (map-set proposals proposal-id
            (merge proposal
                {
                    yes-votes: (if vote-for
                        (+ (get yes-votes proposal) token-balance)
                        (get yes-votes proposal)
                    ),
                    no-votes: (if vote-for
                        (get no-votes proposal)
                        (+ (get no-votes proposal) token-balance)
                    )
                }
            )
        )
        
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let (
        (proposal (unwrap! (get-proposal proposal-id) ERR-PROPOSAL-NOT-FOUND))
        (total-votes (+ (get yes-votes proposal) (get no-votes proposal)))
        (quorum-requirement (* (var-get total-tokens) (var-get quorum-percentage)))
    )
        ;; Validate execution conditions
        (asserts! (not (get executed proposal)) ERR-INVALID-PROPOSAL)
        (asserts! (not (is-voting-open proposal-id)) ERR-VOTING-CLOSED)
        (asserts! (>= (* total-votes u100) quorum-requirement) ERR-QUORUM-NOT-MET)
        
        ;; Mark proposal as executed
        (map-set proposals proposal-id
            (merge proposal {executed: true})
        )
        
        (ok true)
    )
)

;; Administrative functions
(define-public (mint-tokens (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        
        ;; Update recipient balance
        (let (
            (current-balance (get-token-balance recipient))
        )
            ;; Set new balance
            (map-set token-balances
                recipient
                (+ current-balance amount)
            )
            
            ;; Update total token supply
            (var-set total-tokens (+ (var-get total-tokens) amount))
            
            (ok true)
        )
    )
)

(define-public (update-voting-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (var-set voting-period new-period)
        (ok true)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (var-set contract-owner new-owner)
        (ok true)
    )
)
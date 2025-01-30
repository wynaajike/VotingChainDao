# VotingChainDAO

VotingChainDAO is a decentralized governance contract that allows token holders to create and vote on proposals. It ensures a fair and transparent decision-making process by leveraging token-based voting mechanisms.

## Features
- **Proposal Creation**: Token holders with sufficient tokens can create governance proposals.
- **Voting Mechanism**: Token holders can vote on proposals, with each token representing a vote.
- **Quorum Requirement**: A proposal can only be executed if it meets the quorum threshold.
- **Token Management**: The contract allows minting of governance tokens.
- **Administrative Functions**: The contract owner can update parameters such as the voting period and transfer ownership.

## Constants and Error Codes
- `ERR-NOT-TOKEN-OWNER (u1)`: The caller does not own tokens.
- `ERR-INVALID-PROPOSAL (u2)`: The proposal is invalid.
- `ERR-DUPLICATE-PROPOSAL (u3)`: The proposal already exists.
- `ERR-PROPOSAL-NOT-FOUND (u4)`: The specified proposal does not exist.
- `ERR-ALREADY-VOTED (u5)`: The caller has already voted on the proposal.
- `ERR-INSUFFICIENT-TOKENS (u6)`: The caller lacks the required tokens.
- `ERR-VOTING-CLOSED (u7)`: The voting period has ended.
- `ERR-QUORUM-NOT-MET (u8)`: The proposal did not meet the quorum.
- `ERR-UNAUTHORIZED (u9)`: The caller is not authorized to perform the action.

## Data Variables
- `contract-owner`: Stores the address of the contract owner.
- `proposal-count`: Keeps track of the total number of proposals.
- `min-tokens-to-propose`: Minimum tokens required to create a proposal.
- `quorum-percentage`: Percentage of total tokens required for a proposal to pass.
- `voting-period`: Duration in blocks for which voting remains open.
- `total-tokens`: Total supply of governance tokens.

## Key Functions
### Read-Only Functions
- `get-proposal(proposal-id)`: Retrieves details of a proposal.
- `get-vote(proposal-id, voter)`: Checks if a user has voted on a proposal.
- `get-token-balance(address)`: Returns the token balance of a user.
- `get-total-tokens()`: Returns the total token supply.
- `get-contract-owner()`: Returns the address of the contract owner.
- `is-voting-open(proposal-id)`: Checks if voting is still open for a proposal.

### Public Functions
- `create-proposal(title, description)`: Allows token holders to create proposals.
- `vote(proposal-id, vote-for)`: Allows token holders to vote on proposals.
- `execute-proposal(proposal-id)`: Executes a proposal if it meets the quorum.

### Administrative Functions
- `mint-tokens(amount, recipient)`: Mints new tokens to a specified address.
- `update-voting-period(new-period)`: Updates the voting period.
- `transfer-ownership(new-owner)`: Transfers contract ownership to another address.

## How It Works
1. **Create Proposal**: A token holder submits a proposal with a title and description.
2. **Vote on Proposal**: Token holders vote for or against the proposal.
3. **Quorum Check**: If the required quorum is met, the proposal can be executed.
4. **Execute Proposal**: The contract marks the proposal as executed once it passes.

## Security Considerations
- Only the contract owner can mint tokens and update governance parameters.
- Voters can only cast one vote per proposal.
- Proposals must meet quorum requirements before execution.

## License
This project is open-source and available under the MIT License.
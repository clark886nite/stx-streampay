 stx-streampay

A Clarity smart contract for continuous streaming payments of STX tokens on the Stacks blockchain. This contract enables users to create, manage, and withdraw from real-time payment streams, allowing seamless recurring payments such as subscriptions, payroll, and more.

---

 Features

- **Start Stream:** Initiate a continuous STX payment stream with a specified flow rate.
- **Stop Stream:** Terminate an active payment stream at any time.
- **Withdraw Funds:** Stream recipients can withdraw the available streamed STX at any point.
- **Stream Management:** Securely track stream ownership and permissions.
- **Real-time Balance:** Calculate owed amounts based on elapsed time and flow rate.
- **Gas Efficiency:** Minimized on-chain operations to reduce fees.

---

 How It Works

1. **Sender** calls `start-stream` specifying the recipient and the amount per second to stream.
2. STX tokens accumulate over time in the stream, which the **recipient** can withdraw partially or fully anytime.
3. **Sender** can stop the stream, halting further accrual.
4. The contract tracks all streams and balances securely on-chain.

---

 Functions

- `start-stream(recipient: principal, flow-rate: uint) -> (response bool uint)`
- `stop-stream(recipient: principal) -> (response bool uint)`
- `withdraw() -> (response bool uint)`
- `get-stream-info(sender: principal, recipient: principal) -> (optional (stream-details))`
- `get-balance(account: principal) -> uint`

*(Full function signatures and documentation available in the code comments)*

---

 Requirements

- Stacks Blockchain (Testnet or Mainnet)
- Clarity language compiler and development tools

---

 Usage

1. Deploy the contract to the Stacks blockchain.
2. Use Clarity SDK or command line tools to interact with the contract functions.
3. Integrate with your front-end or dApp to enable users to manage payment streams.

---

 Testing

The repository includes basic unit tests covering:

- Stream creation and termination
- Withdrawal functionality
- Balance calculations

Run tests using Clarinet or your preferred Clarity testing framework.

---

## License

MIT License

---






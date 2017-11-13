{
  callvalue iszero       dispatch jumpi // Skip deposit if no value sent
  32 not sload callvalue add            // Calculate new total supply
  32 not sstore                         // Save new total supply to storage
  caller sload callvalue add            // Calculate new target balance
  caller sstore                         // Save new target balance to storage
  // Emit `Deposit(address indexed, uint)'
  0xe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c
  callvalue 0 mstore caller swap1 32 0 log2

dispatch:
  0 calldataload 224 2 exp div          // Determine function signature
  dup1 0x23b872dd eq transferFrom jumpi
  dup1 0x70a08231 eq    balanceOf jumpi
  dup1 0x18160ddd eq  totalSupply jumpi
  dup1 0x2e1a7d4d eq     withdraw jumpi
  dup1 0x095ea7b3 eq      approve jumpi
  dup1 0xdd62ed3e eq    allowance jumpi
  dup1 0xa9059cbb eq     transfer jumpi
exit:
  stop
fail:
  invalid

balanceOf:
  4 calldataload sload                  // Load balance from storage
  0 mstore 32 0 return                  // Return balance
totalSupply:
  32 not sload                          // Load supply from storage
  0 mstore 32 0 return                  // Return total supply
allowance:
  36 calldataload 4 calldataload        // Load owner and spender
  0 mstore 32 mstore                    // Write addresses to memory
  64 0 keccak256 sload                  // Load allowance from storage
  0 mstore 32 0 return                  // Return allowance

transfer:
  36 calldataload
  4 calldataload
  caller
  AttemptTransfer jump
transferFrom:
  68 calldataload
  36 calldataload
  4 calldataload
AttemptTransfer:
  224 2 exp dup3 dup3 or div exit jumpi // Abort if garbage in addresses
  dup2 sload dup2 sload                 // Load source and target balances
  dup5 dup2 lt               exit jumpi // Abort if insufficient balance
  dup3 caller eq  PerformTransfer jumpi // Skip ahead if source is caller
  dup3 0 mstore caller 32 mstore
  32 0 keccak256                        // Determine allowance storage slot
  dup1 sload                            // Load allowance from storage
  1 not dup2 eq   PerformTransfer jumpi // Skip ahead if allowance is max
  dup7 dup2 lt               exit jumpi // Abort if allowance is too low
  dup7 swap2 sub swap2 sstore           // Save new allowance to storage
PerformTransfer:
  dup5 swap3 sub dup3 sstore            // Save source balance to storage
  dup4 swap2 add dup3 sstore            // Save target balance to storage
  // Emit `Transfer(address indexed, address indexed, uint)'
  0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
  swap4 0 mstore 32 0 log3
  1 0 mstore 32 0 return                // Return true

approve:
  36 calldataload 4 calldataload        // Load spender and new allowance
  caller 0 mstore dup2 32 mstore
  64 0 keccak256                        // Determine allowance storage slot
  dup3 sstore                           // Write new allowance to storage
  // Emit `Approval(address indexed, address indexed, uint)'
  0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
  swap3 0 mstore caller swap1 0 0 log3
  1 0 mstore 32 0 return                // Return true

withdraw:
  4 calldataload                        // Load amount to withdraw
  caller sload                          // Load source balance from storage
  dup2 dup2 sub                         // Calculate new source balance
  dup2 swap1 gt              exit jumpi // Abort if underflow occurred
  caller sstore                         // Save new source balance to storage
  1 not dup2 sload                      // Load total supply from storage
  dup2 swap1 sub                        // Decrement total supply
  1 not sstore                          // Save new total supply to storage
  0 0 0 0                               // No return data and no calldata
  dup5 caller                           // Send withdrawal amount to caller
  gaslimit call iszero       fail jumpi // Make call, aborting on failure
  // Emit `Withdrawal(address indexed, uint)'
  0x7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b65
  swap1 0 mstore caller swap1 32 0 log2
  1 0 mstore 32 0 return                // Return true
}
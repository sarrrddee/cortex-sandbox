# Cortex Sandbox

An AI action simulation and approval sandbox on the Stacks blockchain. Cortex Sandbox enables AI agents to propose actions with cryptographic payload verification, allows human controllers to approve or reject proposals, and provides verification gates to ensure actions are approved before execution.

## Overview

Cortex Sandbox is a Clarity smart contract that implements a human-in-the-loop approval system for AI agent actions. AI agents submit action proposals with type categorization and hashed payloads, contract owners review and approve or reject proposals, and the system maintains immutable records of all decisions with timestamps for accountability.

## Features

✓ **Action Submission** - AI agents submit actions with type and payload-hash  
✓ **Human Approval Gate** - Contract owner reviews and approves/rejects proposals  
✓ **Decision Tracking** - Track approval/rejection status with decision timestamps  
✓ **Payload Verification** - Support off-chain payload verification via 32-byte hash  
✓ **Action Classification** - Type field enables categorization and filtering of actions  
✓ **Decision Finality** - Prevents re-approval or re-rejection once decided  
✓ **Immutable Audit Trail** - All actions tracked with proposer and decision history  

## Contract Functions

### Agent Functions

- `submit-action(action-type, payload-hash)` - Submit action for approval
  - `action-type`: String categorizing the action (max 32 ASCII characters)
  - `payload-hash`: 32-byte cryptographic hash of the action payload
  - Returns: Unique action ID
  - Can be called by any principal (AI agents, contracts, users)

### Owner Functions

- `approve-action(id)` - Approve a submitted action
  - `id`: Action ID to approve
  - Only callable by contract owner
  - Prevents approval if action already decided
  - Returns: Success confirmation or error code

- `reject-action(id)` - Reject a submitted action
  - `id`: Action ID to reject
  - Only callable by contract owner
  - Prevents rejection if action already decided
  - Returns: Success confirmation or error code

### Read-Only Functions

- `is-approved(id)` - Check if action is approved
  - Returns: Boolean true if approved, false otherwise
  - Enables verification gates before execution

- `get-action(id)` - Query complete action details
  - Returns: Proposer, action-type, payload-hash, approval status, rejection status, timestamps

- `action-count` - Get total number of actions submitted
  - Returns: Next available action ID (total action count)

## State Management

### Configuration Variables

- **contract-owner**: Owner principal (set at deployment via tx-sender)
- **next-action-id**: Auto-incrementing counter for unique action IDs

### Storage Maps

- **actions**: Stores action data keyed by unique ID
  - `proposer`: Principal who submitted the action
  - `action-type`: String categorizing action (max 32 ASCII characters)
  - `payload-hash`: 32-byte cryptographic hash of payload
  - `approved`: Boolean indicating approval status
  - `rejected`: Boolean indicating rejection status
  - `created-at`: Block height of submission
  - `decided-at`: Block height of decision

## Action Lifecycle

# Alloy Model of the Raft Consensus Algorithm
An attempt at creating a simple model of the Raft Consensus Algorithm in
[Alloy](http://alloy.mit.edu/alloy/).

This project started its life as a semester project for the course CS 810B
Modeling and Analysis of Software Security.  The tag `v0.1` represents the
project's state as I submitted it for the course. It may or may not evolve from
there.

## Raft
The [Raft Consensus Algorithm](https://raft.github.io/) is designed to be an
easy to understand distributed consensus algorithm. There is a great
visualization of how it operates at
[thesecretlivesofdata.com/raft/](http://thesecretlivesofdata.com/raft/).

## My Model
As it currently stands this model breaks time into two categories:

- States
- Terms

A State is essentially a clock tick, some unit of time to break down the model
by. While a Term is essentially the lifetime of a leader Node (almost analogous
to Raft's definition of a Term with the exception that the model doesn't handle
elections at this time).

The State signature is the only one making use of Alloy's builtin
`util/ordering`.  Terms are constrained to have only contiguous States. Terms do
not use `util/ordering` in order to keep the model relatively simple.

States may also hold messages from the leader of the current Term. These
messages are just a relation from the leader to a single value that all follower
Nodes should update to.

### Storing and Updating Values
Nodes currently store a single value (rather than the log in Raft) as an
integer. The update process for the model currently specifies that at some time
the leader is updated and sends out a message telling follower Nodes to update
to that value. If and only if a Node receives a message from a leader to change
to a value then may a Node change to that value.

Alloy's lack of an assignment operator makes defining an 'Update' quite
difficult. Therefore, this model simply increments the value of the leader Node
(using plus[]) rather than assigning a new one, follower Nodes are then changed
to the value of the leader. Leaders may change their value at any time (as Alloy
tends to do) but have been constrained that they should send a message to update
followers if their value changes.

The 'Update' predicate specifies that 'Consensus' should hold before doing an
update this is not really a constraint of Raft but is here to prevent Alloy from
changing the leader's value too much (i.e. the 'ConsensusAfterUpdate' assertion
previously would not hold because the leader's value changed immediately after
starting the update).

### The 'show' Predicate
The 'show' predicate is setup to have at least some pair of States in the same
Term for which an update takes place, after which the two Nodes should reach
'Consensus' because the 'ConsensusAfterUpdate' assertion holds. After this point
the leader is free to change value and followers should update to that value but
there is no guarantee that the leader will remain at that value. In this way the
model may not end in 'Consensus'.

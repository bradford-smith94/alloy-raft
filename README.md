#Alloy Model of the Raft Consensus Algorithm
An attempt at creating a simple model of the Raft Consensus Algorithm in
[Alloy](http://alloy.mit.edu/alloy/).

##Raft
The [Raft Consensus Algorithm](https://raft.github.io/) is designed to be an
easy to understand distributed consensus algorithm. There is a great
visualization of how it operates at
[thesecretlivesofdata.com/raft/](http://thesecretlivesofdata.com/raft/).

##My Model
As it currently stands this model breaks time into two categories:

- States
- Terms

A State is essentially a clock tick, some unit of time to break down the model
by. While a Term is essentially the lifetime of a leader Node (almost analogous
to Raft's definition of a Term with the exception that the model doesn't handle
elections at this time).

###Storing and Updating Values
Nodes currently store a single value (rather than the log in Raft) as an
integer. The update process for the model currently specifies that at some time
the leader is updated to a value and at some time in the same Term after that
the Nodes reach consensus on that value.

###Issues
Currently Nodes can change values at random, they need to be restricted so that
values can only change through the update process.

/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 12/20/2016
 */

module raft

open util/ordering[State]

sig State{
    -- State can have a message sent by the leader
    message: Node -> Int
}{
    -- State must be a part of only one election Term
    one @states.this
}
sig Term{
    states: set State,
    leader: one Node
}{
    -- election Term must have some states
    some states
    #states > 1

    -- Term has contiguous states
    no s1, s2, s3: State | s1 in states and s3 in states and s2 !in states and
        between[s2, s1, s3]
}
sig Node{
    value: State -> one Int -- a node has one value at a given state
}

-- State s2 is between s1 and s3
pred between[s2, s1, s3: State] {
    lt[s1, s2]
    lt[s2, s3]
}

assert StatesInOrder {
    all s1, s2, s3: State | all t: Term |
        lt[s1, s2] and lt[s2, s3] and s1 in t.states and
        s3 in t.states => s2 in t.states
}
check StatesInOrder for 10


/* TODO this may over-constrain the model, for some reason it prevents the
 * 'show' predicate from producing an instance
fact {
    -- only leaders send update messages
    all s: State | some s.message => s.message = states.s.leader -> Int
}

assert NoFollowerMessages {
    all s: State | all n: Node | no n & states.s.leader => s.message != n -> Int
}
check NoFollowerMessages for 10
*/


fact {
    /* a Node that is leader of one term implies that Node will not be leader
     * next term (otherwise we wouldn't have needed an election)
     */
    no s1, s2: State | lt[s1, s2] and states.s1 != states.s2 and
        states.s1.leader = states.s2.leader
}

assert NoConsecutiveLeaders {
    all n: Node | all s1, s2, s3: State | between[s2, s1, s3] and
        states.s2 != states.s1 and states.s2 != states.s3 and
        some states.s2.leader & n => (no states.s1.leader & n and
        no states.s3.leader & n)
}
check NoConsecutiveLeaders for 10


pred Consensus [s: State] {
    -- all Nodes have the same value
    all n1, n2: Node | n1.value[s] = n2.value[s]
}

fact {
    -- a Node's value only changes if the leader told it to

    -- if a Node's value has changed, then the leader must have told it to
    all s1, s2: State | all n: Node | lt[s1, s2] and n.value[s1] != n.value[s2]
        => s1.message = states.s1.leader -> n.value[s2]

    -- if the leader tells Nodes to change value, they must
    all s1, s2: State | all n: Node | some v: Int | lt[s1, s2] and
        s1.message = states.s1.leader -> v =>
        n.value[s2] = v

    -- a leader can only send a message with it's value
    all s: State | all v: Int | some s.message.v =>
        states.s.leader.value[s] = v
}


pred Update [s1, s2: State, v: Int] {
    -- updates go through the leader Node
    s2 = s1.next
    states.s2.leader.value[s2] = v
    s2.message = states.s2.leader -> v
}

assert ConsensusAfterUpdate {
    all s1, s2, s3: State | some v: Int | lt[s2, s3] and Update[s1, s2, v] and Consensus[s3]
}
check ConsensusAfterUpdate for 10

pred show{
    some s1, s2: State | some v: Int | Update[s1, s2, v]
}
run show for 6 but exactly 2 Node, 3 Term

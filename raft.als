/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 12/11/2016
 */

module raft

open util/ordering[Term]
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
}
sig Node{
    value: State -> one Int -- a node has one value at a given state
}

fact {
    /* Terms and States are ordered, that is, a Term contains only States from
     * before those contained in the next Term
     */
    all t1, t2: Term | all s1, s2: State |
        (lt[t1, t2] and s1 in t1.states and s2 in t2.states) => lt[s1, s2]
}

assert StatesInOrder {
    all s1, s2, s3: State | all t: Term |
        lt[s1, s2] and lt[s2, s3] and s1 in t.states and
        s3 in t.states => s2 in t.states
}
check StatesInOrder for 10


fact {
    -- only leaders send update messages
    all s: State | all v: Int | some s.message => s.message = states.s.leader -> v
}

assert NoFollowerMessages {
    all s: State | all n: Node | all v: Int | no n & states.s.leader => s.message != n -> v
}
check NoFollowerMessages for 10


fact {
    /* a Node that is leader of one term implies that Node will not be leader
     * next term (otherwise we wouldn't have needed an election)
     */
    all n: Node | all t: Term | some t.leader & n => no next[t].leader & n
}

assert NoConsecutiveLeaders {
    all n: Node | all t: Term | some t.leader & n => (no next[t].leader & n and
        no prev[t].leader & n)
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


pred Update [s: State, v: Int] {
    -- updates go through the leader Node
    states.s.leader.value[s] = v
    s.message = states.s.leader -> v
    -- some s1: State | s1 in states.s.states and gt[s1, s] and Consensus[s1]
}

assert ConsensusAfterUpdate {
    all s1, s2: State | all v: Int | lt[s1, s2] and Update[s1, v] and Consensus[s2]
}
check ConsensusAfterUpdate for 10

pred show{
    some s: State | all v: Int | Update[s, v]
}
run show for 6 but exactly 2 Node, 3 Term

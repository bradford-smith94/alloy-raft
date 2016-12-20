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

    /* Term has contiguous states (no triplet of States such that the middle
     * State is not in the same Term)
     */
    no s1, s2, s3: State | s1 in states and s3 in states and s2 !in states and
        between[s2, s1, s3]
}

sig Node{
    value: State -> one Int -- a node has one value at a given State
}


pred between[s2, s1, s3: State] {
    -- State s2 is between s1 and s3
    lt[s1, s2]
    lt[s2, s3]
}

pred inTerm[s1, s2: State] {
    -- State s1 and s2 are in the same Term
    states.s1 = states.s2
}

pred isLeader[n: Node, s: State] {
    -- Node n is the leader during State s
    states.s.leader = n
}


assert StatesInOrder {
    all s1, s2, s3: State | all t: Term |
        lt[s1, s2] and lt[s2, s3] and s1 in t.states and
        s3 in t.states => s2 in t.states
}
check StatesInOrder for 10


fact {
    -- only leaders send update messages
    all s: State | all n: Node | some v: Int | (isLeader[n, s] and
        some s.message) => s.message = n -> v
}

assert NoFollowerMessages {
    no s: State | all n: Node | !isLeader[n, s] => s.message = n -> Int
}
check NoFollowerMessages for 10


fact {
    /* there are no two States directly after one another that are not in the
     * same Term such that a Node is the leader in both Terms (otherwise we
     * wouldn't have needed to change to another Term)
     */
    no s1, s2: State | s2 = s1.next and !inTerm[s1, s2] and
        states.s1.leader = states.s2.leader
}

assert NoConsecutiveLeaders {
    all n: Node | all s1, s2: State | !inTerm[s1, s2] and s2 = s1.next and
        isLeader[n, s2] => !isLeader[n, s1]
}
check NoConsecutiveLeaders for 10


pred Consensus [s: State] {
    -- all Nodes have the same value
    all disj n1, n2: Node | n1.value[s] = n2.value[s]
}

fact {
    -- a Node's value only changes if the leader told it to

    /* if a Node's value has changed, and that Node is not a leader, then the
     * leader must have told it to
     */
    all s1, s2: State | all n: Node | (lt[s1, s2] and !isLeader[n, s1] and
        !isLeader[n, s2] and n.value[s1] != n.value[s2]) =>
        s1.message = states.s1.leader -> n.value[s2]

    -- if the leader tells Nodes to change value, they must
    all s1, s2: State | all n: Node | all v: Int | (lt[s1, s2] and
        !isLeader[n, s1] and !isLeader[n, s2] and
        s1.message = states.s1.leader -> v) =>
        n.value[s2] = v

    -- if the leader's value changes it must send a message
    all s1, s2: State | all n: Node | (lt[s1, s2] and isLeader[n, s1] and
        isLeader[n, s2] and n.value[s1] != n.value[s2]) =>
        s2.message = n -> n.value[s2]

    -- a leader can only send a message with it's value
    all s: State | all v: Int | some s.message.v =>
        states.s.leader.value[s] = v
}


pred Update [s1, s2: State] {
    -- updates go through the leader Node
    Consensus[s1]
    inTerm[s1, s2]
    s2 = s1.next
    states.s2.leader.value[s2] = plus[states.s1.leader.value[s1], 1]
    s2.message = states.s2.leader -> plus[states.s1.leader.value[s1], 1]
}

assert ConsensusAfterUpdate {
    all s1, s2, s3: State | (between[s2, s1, s3] and inTerm[s1, s2] and
        inTerm[s2, s3] and Update[s1, s2]) => Consensus[s3]
}
check ConsensusAfterUpdate for 10

pred show{
    /* this will show us at least some pair of States in the same Term in which
     * an Update takes place, there should be Consensus at some point after the
     * update
     */
    some s1, s2: State | inTerm[s1, s2] and Update[s1, s2]
}
run show for 6 but exactly 2 Node, 3 Term

/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 12/07/2016
 */

module raft

open util/ordering[Term]
open util/ordering[State]
-- open util/boolean

sig State{}{
    -- State must be a part of only one election Term
    one @states.this
}
sig Term{
    states: set State,
    leader: one Node
}{
    -- election Term must have some states
    some states
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
        lt[s1, s2] and lt[s2, s3] and s1 in t.states and s3 in t.states => s2 in t.states
}
check StatesInOrder for 40

fact {
    /* a Node that is leader of one term implies that Node will not be leader
     * next term (otherwise we wouldn't have needed an election)
     */
    all n: Node | all t: Term | some t.leader & n => no next[t].leader & n
}

pred show{}
run show for 5 but exactly 2 Node, 3 Term

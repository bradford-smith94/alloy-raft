/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 12/06/2016
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
    leader: set State -> lone Node
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
        ((lt[t1, t2] and s1 in t1.states and s2 in t2.states) => lt[s1, s2]) and
        ((gt[t1, t2] and s1 in t1.states and s2 in t2.states) => gt[s1, s2])
    -- TODO: might not need the greater than line, candidate for cleanup
    -- TODO: need to make sure States can't go out of order between Terms: State0 -> State3 is possible
}

fact {
    -- there can be at most one leader for every election Term
    all t: Term | some s: State | s in t.states and one t.leader[s] & Node
    -- TODO: node will stay leader for the rest of term

    -- a Node that is leader of one term implies that Node will not be leader
    -- next term (otherwise we wouldn't have needed an election)
    all n: Node | some t: Term | some t.leader.n => no next[t].leader.n
}

pred show{}
run show for 5 but exactly 2 Node, 2 Term

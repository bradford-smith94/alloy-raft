/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 11/29/2016
 */

module raft

open util/ordering[Term]
open util/ordering[State]
open util/boolean

sig State{}{
    -- State must be a part of only one election Term
    one @states.this
}
sig Term{
    states: set State
}{
    -- election Term must have some states
    some states
}
sig Node{
    leader: State -> one Bool,
    --candidate: State -> one Bool,
    follower: State -> one Bool,
    value: State -> one Int -- a node has one value at a given state
}{
    -- a node must be either leader or follower but not both
    all s: State | isTrue[leader[s]] => !isTrue[follower[s]] or
                  !isTrue[leader[s]] => isTrue[follower[s]] or
                  isTrue[follower[s]] => !isTrue[leader[s]] or
                  !isTrue[follower[s]] => isTrue[leader[s]]
}

fact {
    /* Terms and States are ordered, that is, a Term contains only States from
     * before those contained in the next Term
     */
    all t1, t2: Term | all s1, s2: State |
        ((lt[t1, t2] and s1 in t1.states and s2 in t2.states) => lt[s1, s2]) and
        ((gt[t1, t2] and s1 in t1.states and s2 in t2.states) => gt[s1, s2])
    -- TODO: might not need the greater than line, candidate for cleanup
}

fact {
    -- there can be only one leader for every election Term
    -- all t: Term | all n: Node | one n.term & t && isTrue[n.leader]
}

pred show{}
run show for 5 but exactly 2 Node, 2 Term

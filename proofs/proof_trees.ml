(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* $Id$ *)

open Closure
open Util
open Names
open Nameops
open Term
open Termops
open Sign
open Evd
open Environ
open Evarutil
open Proof_type
open Tacred
open Typing
open Libnames
open Nametab

(*
let is_bind = function
  | Tacexpr.Cbindings _ -> true
  | _ -> false
*)

(* Functions on goals *)

let mk_goal hyps cl = 
  { evar_hyps = hyps; evar_concl = cl; 
    evar_body = Evar_empty}

(* Functions on proof trees *)

let ref_of_proof pf =
  match pf.ref with
    | None -> failwith "rule_of_proof"
    | Some r -> r

let rule_of_proof pf =
  let (r,_) = ref_of_proof pf in r

let children_of_proof pf = 
  let (_,cl) = ref_of_proof pf in cl
				    
let goal_of_proof pf = pf.goal

let subproof_of_proof pf = match pf.ref with
  | Some (Tactic (_,pf), _) -> pf
  | _ -> failwith "subproof_of_proof"

let status_of_proof pf = pf.open_subgoals

let is_complete_proof pf = pf.open_subgoals = 0

let is_leaf_proof pf = (pf.ref = None)

let is_tactic_proof pf = match pf.ref with
  | Some (Tactic _, _) -> true
  | _ -> false


let pf_lookup_name_as_renamed env ccl s =
  Detyping.lookup_name_as_renamed env ccl s

let pf_lookup_index_as_renamed env ccl n =
  Detyping.lookup_index_as_renamed env ccl n

(*********************************************************************)
(*                  Pretty printing functions                        *)
(*********************************************************************)

open Pp

let db_pr_goal g =
  let env = evar_env g in
  let penv = print_named_context env in
  let pc = print_constr_env env g.evar_concl in
  str"  " ++ hv 0 (penv ++ fnl () ++
                   str "============================" ++ fnl ()  ++
                   str" "  ++ pc) ++ fnl ()


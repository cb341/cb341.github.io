-- Author: cb341 (Dani)
--
-- This document aims to show the steps required in prooving
-- the totality property of natural numbers, namely
--
--   theorem le_total (x y : ℕ) : x ≤ y ∨ y ≤ x
--
-- from first principles, starting at the inductive definition
-- of natural numbers - proving all mediary theorems along the
-- way and ending at QED.
--
-- I use the natural number definitions from the natural numbers
-- Lean game as a basis
--
-- https://adam.math.hhu.de/#/g/leanprover-community/nng4
--
-- And proove theorems on top of that step by step.
import Mathlib.Tactic.Have
import Mathlib.Tactic.Contrapose
import Mathlib.Tactic.ApplyAt
import Mathlib.Tactic.Cases
import Mathlib.Tactic.NthRewrite
import Mathlib.Tactic.Tauto
import Lean.Elab.Tactic.Basic
import Lean.Elab.Tactic.Induction
import Batteries.Tactic.OpenPrivate
import Batteries.Data.List.Basic
import Mathlib.Lean.Expr.Basic
import Mathlib.Tactic.Cases
import Lean.Meta.Tactic.Refl
import Lean.Elab.Tactic.Basic
import Mathlib.Lean.Expr.Basic
import Lean.Elab.Tactic.Basic
import Lean.Elab.Tactic.Rewrite
import Mathlib.Tactic.Use
import Mathlib.Lean.Meta.Simp

-- The following definitions and axioms were taken over / modified from
-- the Apache Licensed NNG4 environment I am familiar with.
-- I do not take ownership over the folllowing definitions
-- but I do acknowledge modifications.
--
-- https://github.com/leanprover-community/NNG4
--
-- Disclaimer: This is not the entirity of the NNG4 env.
-- DX features such as pretty printing,
-- formatting a[118;1:3und more intuitive tactics were not taken over.

-- BEGIN NNG4 --
inductive MyNat where
| zero : MyNat
| succ : MyNat → MyNat
attribute [pp_nodot] MyNat.succ
notation (name := MyNatNotation) (priority := 1000000) "ℕ" => MyNat

namespace MyNat

instance : Inhabited MyNat where
  default := MyNat.zero

def ofNat (x : Nat) : MyNat :=
  match x with
  | Nat.zero   => MyNat.zero
  | Nat.succ b => MyNat.succ (ofNat b)

def toNat (x : MyNat) : Nat :=
  match x with
  | MyNat.zero   => Nat.zero
  | MyNat.succ b => Nat.succ (toNat b)

instance instofNat {n : Nat} : OfNat MyNat n where
  ofNat := ofNat n

instance : ToString MyNat where
  toString p := toString (toNat p)

theorem zero_eq_0 : MyNat.zero = 0 := rfl

def one : MyNat := MyNat.succ 0

def pred : ℕ → ℕ
| 0 => 37 -- random (garbage) value according to NNG4
| succ n => n

lemma pred_succ (n : ℕ) : pred (succ n) = n := rfl

def is_zero : ℕ → Prop
| 0 => True
| succ _ => False

lemma is_zero_zero : is_zero 0 = True := rfl
lemma is_zero_succ (n : ℕ) : is_zero (succ n) = False := rfl

theorem zero_ne_succ (a : ℕ) : 0 ≠ succ a := by
  intro h
  rewrite[← is_zero_succ a]
  rewrite[← h]
  rewrite[is_zero_zero]
  trivial

theorem one_eq_succ_zero : 1 = succ 0 := by rfl
theorem two_eq_succ_one : 2 = succ 1 := by rfl
theorem three_eq_succ_two : 3 = succ 2 := by rfl
theorem four_eq_succ_three : 4 = succ 3 := by rfl

-- addition
opaque add : MyNat → MyNat → MyNat

instance instAdd : Add MyNat where
  add := MyNat.add

axiom add_zero (a : MyNat) : a + 0 = a
axiom add_succ (a d : MyNat) : a + (succ d) = succ (a + d)

-- inequality
def le (a b : ℕ) :=  ∃ (c : ℕ), b = a + c
instance : LE MyNat := ⟨MyNat.le⟩
-- END NNG4 --

-- What follow are all the theorems required to proove the totality of ℕ.
-- The Lean4Game environment provided me with placeholders:
--
-- theorem succ_eq_add_one n : succ n = n + 1 := by
--   sorry
--
-- The theorems were proven by me as an excercise.

-- BEGIN DANI --

theorem succ_eq_add_one n : succ n = n + 1 := by
  rewrite[one_eq_succ_zero]
  rewrite[add_succ]
  rewrite[add_zero]
  rfl

theorem zero_add (n : ℕ) : 0 + n = n := by
  induction n with
  | zero =>
    rewrite[zero_eq_0]
    rewrite[add_zero]
    rfl
  | succ d hd =>
    rewrite[add_succ]
    rewrite[hd]
    rfl

theorem succ_add (a b : ℕ) : succ a + b = succ (a + b) := by
  induction b with
  | zero =>
    rewrite[zero_eq_0]
    rewrite[add_zero]
    rewrite[add_zero]
    rfl
  | succ d hb =>
    rewrite[add_succ]
    rewrite[hb]
    rewrite[add_succ]
    rfl

theorem add_comm (a b : ℕ) : a + b = b + a := by
  induction b with
  | zero =>
    rewrite[zero_eq_0]
    rewrite[add_zero]
    rewrite[zero_add]
    rfl
  | succ n hn =>
    rewrite[add_succ]
    rewrite[succ_add]
    rewrite[hn]
    rfl

theorem add_assoc (a b c : ℕ) : a + b + c = a + (b + c) := by
  induction b with
  | zero =>
    rewrite[zero_eq_0]
    rewrite[add_zero]
    rewrite[zero_add]
    rfl
  | succ n hn =>
    rewrite[add_succ]
    rewrite[succ_add]
    rewrite[succ_add]
    rewrite[add_succ]
    rewrite[hn]
    rfl

theorem zero_le (x : ℕ) : 0 ≤ x := by
  use x
  rewrite[zero_add]
  rfl

theorem le_succ_self (x : ℕ) : x ≤ succ x := by
  use 1
  exact succ_eq_add_one x

-- This is the climax - the proof we have been approaching thus far
theorem le_total (x y : ℕ) : x ≤ y ∨ y ≤ x := by
  induction y with
  | zero =>
    right
    exact zero_le x
  | succ d hd =>
    cases hd with
    | inl hl =>
      cases' hl with c hc
      rewrite[hc]
      left
      rewrite[succ_eq_add_one]
      use c + 1
      rewrite[← add_assoc]
      rfl
    | inr hr =>
      cases' hr with c hc
      cases c with
      | zero =>
        rewrite[zero_eq_0] at hc
        rewrite[add_zero d] at hc
        left
        rewrite[hc]
        exact le_succ_self d
      | succ a =>
        rewrite[add_succ] at hc
        right
        rewrite[hc]
        use a
        rewrite[succ_add]
        rfl

end MyNat

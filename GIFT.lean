-- GIFT: Geometric Integration of Fundamental Topologies
-- Main entry point for Lean 4 formalization
-- Version: 3.4.26 (33 published relations, 15 axioms = 4 prediction-chain + 11 K3 interval-cert, 0 sorry)

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORE & RELATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

import GIFT.Core
import GIFT.Relations
import GIFT.Relations.GaugeSector
import GIFT.Relations.NeutrinoSector
import GIFT.Relations.LeptonSector
import GIFT.Relations.Cosmology
import GIFT.Relations.CompactificationCorrection

-- ═══════════════════════════════════════════════════════════════════════════════
-- MATHEMATICAL FOUNDATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

import GIFT.Foundations
import GIFT.Algebraic
import GIFT.Geometry

-- Joyce existence theorem
import GIFT.Sobolev
import GIFT.DifferentialForms
import GIFT.ImplicitFunction
import GIFT.IntervalArithmetic
import GIFT.Joyce

-- Dimensional hierarchy & golden ratio
import GIFT.Foundations.GoldenRatioPowers
import GIFT.Hierarchy

-- ═══════════════════════════════════════════════════════════════════════════════
-- OBSERVABLES & SPECTRAL THEORY
-- ═══════════════════════════════════════════════════════════════════════════════

import GIFT.Observables
import GIFT.Spectral
import GIFT.Predictions.CP.DeltaCPNuBarConjecture

-- ═══════════════════════════════════════════════════════════════════════════════
-- CERTIFICATE (modular: Foundations / Predictions / Spectral)
-- ═══════════════════════════════════════════════════════════════════════════════

import GIFT.Certificate.Core

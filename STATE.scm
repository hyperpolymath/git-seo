;;; STATE.scm - Project Checkpoint
;;; git-seo
;;; Format: Guile Scheme S-expressions
;;; Purpose: Preserve AI conversation context across sessions
;;; Reference: https://github.com/hyperpolymath/state.scm

;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

;;;============================================================================
;;; METADATA
;;;============================================================================

(define metadata
  '((version . "0.1.0")
    (schema-version . "1.0")
    (created . "2025-12-15")
    (updated . "2025-12-17")
    (project . "git-seo")
    (repo . "github.com/hyperpolymath/git-seo")))

;;;============================================================================
;;; PROJECT CONTEXT
;;;============================================================================

(define project-context
  '((name . "git-seo")
    (tagline . "Make your repositories discoverable")
    (version . "0.1.0")
    (license . "AGPL-3.0-or-later")
    (rsr-compliance . "gold-target")

    (tech-stack
     ((primary . "Julia 1.9+")
      (framework . "Comonicon.jl CLI")
      (http . "HTTP.jl")
      (json . "JSON3.jl")
      (ci-cd . "GitHub Actions + GitLab CI + Bitbucket Pipelines")
      (security . "TruffleHog + OSSF Scorecard")))))

;;;============================================================================
;;; CURRENT POSITION
;;;============================================================================

(define current-position
  '((phase . "v0.1 - Initial Setup and RSR Compliance")
    (overall-completion . 40)

    (components
     ((rsr-compliance
       ((status . "complete")
        (completion . 100)
        (notes . "SHA-pinned actions, SPDX headers, multi-platform CI")))

      (documentation
       ((status . "foundation")
        (completion . 50)
        (notes . "README exists, META/ECOSYSTEM/STATE.scm fully populated")))

      (testing
       ((status . "basic")
        (completion . 30)
        (notes . "Unit tests for URL parsing, README analysis, scoring")))

      (core-functionality
       ((status . "functional")
        (completion . 60)
        (notes . "analyze, compare, optimize commands implemented")))

      (security
       ((status . "complete")
        (completion . 100)
        (notes . "All GitHub Actions SHA-pinned, TruffleHog secret scanning")))))

    (working-features
     ("RSR-compliant CI/CD pipeline"
      "Multi-platform mirroring (GitHub, GitLab, Bitbucket)"
      "SPDX license headers on all files"
      "SHA-pinned GitHub Actions"
      "Repository URL parsing (GitHub, GitLab, Bitbucket)"
      "README analysis and scoring"
      "SEO score calculation with recommendations"
      "JSON and text output formats"))))

;;;============================================================================
;;; ROUTE TO MVP
;;;============================================================================

(define route-to-mvp
  '((target-version . "1.0.0")
    (definition . "Stable release with comprehensive documentation and tests")

    (milestones
     ((v0.2
       ((name . "Core Functionality Complete")
        (status . "in-progress")
        (items
         ("Add Codeberg forge support"
          "Implement GitLab and Bitbucket token authentication"
          "Add integration tests with mock APIs"
          "Improve error handling and user feedback"
          "Add --quiet and --format flags"))))

      (v0.3
       ((name . "Enhanced Analysis")
        (status . "pending")
        (items
         ("Add language-specific scoring (README.rst, README.adoc support)"
          "Detect CONTRIBUTING.md, CHANGELOG.md presence"
          "Analyze issue/PR template presence"
          "Add social media/website link detection"
          "Cache API responses for rate limiting"))))

      (v0.5
       ((name . "Feature Complete")
        (status . "pending")
        (items
         ("Batch analysis of multiple repositories"
          "Generate optimization PR suggestions"
          "Export to CSV/HTML report formats"
          "Test coverage > 70%"
          "API stability"))))

      (v0.8
       ((name . "Polish and Documentation")
        (status . "pending")
        (items
         ("Comprehensive user documentation"
          "Man page generation"
          "Shell completion scripts"
          "Performance benchmarks"
          "Example scripts and integrations"))))

      (v1.0
       ((name . "Production Release")
        (status . "pending")
        (items
         ("Comprehensive test coverage > 80%"
          "Performance optimization"
          "Security audit complete"
          "Published to Julia General registry"
          "User documentation complete"))))))))

;;;============================================================================
;;; BLOCKERS & ISSUES
;;;============================================================================

(define blockers-and-issues
  '((critical
     ())  ;; No critical blockers

    (high-priority
     ())  ;; No high-priority blockers

    (medium-priority
     ((test-coverage
       ((description . "Limited test infrastructure")
        (impact . "Risk of regressions")
        (needed . "Comprehensive test suites")))))

    (low-priority
     ((documentation-gaps
       ((description . "Some documentation areas incomplete")
        (impact . "Harder for new contributors")
        (needed . "Expand documentation")))))))

;;;============================================================================
;;; CRITICAL NEXT ACTIONS
;;;============================================================================

(define critical-next-actions
  '((immediate
     (("Review and update documentation" . medium)
      ("Add initial test coverage" . high)
      ("Verify CI/CD pipeline functionality" . high)))

    (this-week
     (("Implement core features" . high)
      ("Expand test coverage" . medium)))

    (this-month
     (("Reach v0.2 milestone" . high)
      ("Complete documentation" . medium)))))

;;;============================================================================
;;; SESSION HISTORY
;;;============================================================================

(define session-history
  '((snapshots
     ((date . "2025-12-15")
      (session . "initial-state-creation")
      (accomplishments
       ("Added META.scm, ECOSYSTEM.scm, STATE.scm"
        "Established RSR compliance"
        "Created initial project checkpoint"))
      (notes . "First STATE.scm checkpoint created via automated script"))

     ((date . "2025-12-17")
      (session . "security-review-and-scm-update")
      (accomplishments
       ("SHA-pinned all GitHub Actions (julia-actions/setup-julia, actions/cache)"
        "Fixed placeholder content in META.scm, ECOSYSTEM.scm, STATE.scm"
        "Updated tech-stack documentation"
        "Verified RSR compliance checks pass"
        "Created comprehensive roadmap"))
      (notes . "Security audit and SCM files review by Claude")))))

;;;============================================================================
;;; HELPER FUNCTIONS (for Guile evaluation)
;;;============================================================================

(define (get-completion-percentage component)
  "Get completion percentage for a component"
  (let ((comp (assoc component (cdr (assoc 'components current-position)))))
    (if comp
        (cdr (assoc 'completion (cdr comp)))
        #f)))

(define (get-blockers priority)
  "Get blockers by priority level"
  (cdr (assoc priority blockers-and-issues)))

(define (get-milestone version)
  "Get milestone details by version"
  (assoc version (cdr (assoc 'milestones route-to-mvp))))

;;;============================================================================
;;; EXPORT SUMMARY
;;;============================================================================

(define state-summary
  '((project . "git-seo")
    (version . "0.1.0")
    (overall-completion . 40)
    (next-milestone . "v0.2 - Core Functionality")
    (critical-blockers . 0)
    (high-priority-issues . 0)
    (updated . "2025-12-17")))

;;; End of STATE.scm

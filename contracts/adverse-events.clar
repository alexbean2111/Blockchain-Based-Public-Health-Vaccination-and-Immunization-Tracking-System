;; Adverse Event Reporting Contract
;; Tracks and investigates vaccine side effects and safety concerns

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-REPORT-NOT-FOUND (err u401))
(define-constant ERR-INVALID-INPUT (err u402))
(define-constant ERR-INVALID-SEVERITY (err u403))

;; Data Variables
(define-data-var next-report-id uint u1)

;; Data Maps
(define-map adverse-event-reports
  { report-id: uint }
  {
    patient-demographics: (string-ascii 100),
    vaccine-type: (string-ascii 50),
    manufacturer: (string-ascii 50),
    batch-number: (string-ascii 20),
    administration-date: uint,
    event-onset-date: uint,
    symptoms: (string-ascii 500),
    severity: (string-ascii 20),
    outcome: (string-ascii 50),
    reporter-type: (string-ascii 30),
    provider-id: (string-ascii 50),
    follow-up-required: bool,
    investigation-status: (string-ascii 30),
    created-at: uint,
    updated-at: uint
  }
)

(define-map authorized-reporters
  { reporter-id: (string-ascii 50) }
  {
    name: (string-ascii 100),
    reporter-type: (string-ascii 30),
    authorized: bool,
    created-at: uint
  }
)

(define-map batch-safety-stats
  { batch-number: (string-ascii 20) }
  {
    total-doses: uint,
    total-reports: uint,
    mild-events: uint,
    moderate-events: uint,
    severe-events: uint,
    last-updated: uint
  }
)

(define-map vaccine-safety-stats
  { vaccine-type: (string-ascii 50) }
  {
    total-doses: uint,
    total-reports: uint,
    mild-events: uint,
    moderate-events: uint,
    severe-events: uint,
    last-updated: uint
  }
)

;; Authorization Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-authorized-reporter (reporter-id (string-ascii 50)))
  (match (map-get? authorized-reporters { reporter-id: reporter-id })
    reporter (get authorized reporter)
    false
  )
)

(define-private (is-valid-severity (severity (string-ascii 20)))
  (or (is-eq severity "mild")
      (or (is-eq severity "moderate")
          (is-eq severity "severe")))
)

;; Reporter Management
(define-public (add-authorized-reporter
  (reporter-id (string-ascii 50))
  (name (string-ascii 100))
  (reporter-type (string-ascii 30))
)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (> (len reporter-id) u0) ERR-INVALID-INPUT)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len reporter-type) u0) ERR-INVALID-INPUT)

    (ok (map-set authorized-reporters
      { reporter-id: reporter-id }
      {
        name: name,
        reporter-type: reporter-type,
        authorized: true,
        created-at: block-height
      }
    ))
  )
)

;; Adverse Event Reporting
(define-public (submit-adverse-event-report
  (patient-demographics (string-ascii 100))
  (vaccine-type (string-ascii 50))
  (manufacturer (string-ascii 50))
  (batch-number (string-ascii 20))
  (administration-date uint)
  (event-onset-date uint)
  (symptoms (string-ascii 500))
  (severity (string-ascii 20))
  (outcome (string-ascii 50))
  (reporter-type (string-ascii 30))
  (provider-id (string-ascii 50))
)
  (let
    (
      (report-id (var-get next-report-id))
    )
    (begin
      (asserts! (is-authorized-reporter provider-id) ERR-NOT-AUTHORIZED)
      (asserts! (> (len vaccine-type) u0) ERR-INVALID-INPUT)
      (asserts! (> (len symptoms) u0) ERR-INVALID-INPUT)
      (asserts! (is-valid-severity severity) ERR-INVALID-SEVERITY)
      (asserts! (>= event-onset-date administration-date) ERR-INVALID-INPUT)

      ;; Create adverse event report
      (map-set adverse-event-reports
        { report-id: report-id }
        {
          patient-demographics: patient-demographics,
          vaccine-type: vaccine-type,
          manufacturer: manufacturer,
          batch-number: batch-number,
          administration-date: administration-date,
          event-onset-date: event-onset-date,
          symptoms: symptoms,
          severity: severity,
          outcome: outcome,
          reporter-type: reporter-type,
          provider-id: provider-id,
          follow-up-required: (is-eq severity "severe"),
          investigation-status: "pending",
          created-at: block-height,
          updated-at: block-height
        }
      )

      ;; Update batch safety statistics
      (update-batch-safety-stats batch-number severity)

      ;; Update vaccine safety statistics
      (update-vaccine-safety-stats vaccine-type severity)

      ;; Increment report ID
      (var-set next-report-id (+ report-id u1))
      (ok report-id)
    )
  )
)

(define-private (update-batch-safety-stats (batch-number (string-ascii 20)) (severity (string-ascii 20)))
  (match (map-get? batch-safety-stats { batch-number: batch-number })
    existing-stats
      (let
        (
          (new-mild (if (is-eq severity "mild") (+ (get mild-events existing-stats) u1) (get mild-events existing-stats)))
          (new-moderate (if (is-eq severity "moderate") (+ (get moderate-events existing-stats) u1) (get moderate-events existing-stats)))
          (new-severe (if (is-eq severity "severe") (+ (get severe-events existing-stats) u1) (get severe-events existing-stats)))
        )
        (map-set batch-safety-stats
          { batch-number: batch-number }
          (merge existing-stats {
            total-reports: (+ (get total-reports existing-stats) u1),
            mild-events: new-mild,
            moderate-events: new-moderate,
            severe-events: new-severe,
            last-updated: block-height
          })
        )
      )
    (let
      (
        (mild-count (if (is-eq severity "mild") u1 u0))
        (moderate-count (if (is-eq severity "moderate") u1 u0))
        (severe-count (if (is-eq severity "severe") u1 u0))
      )
      (map-set batch-safety-stats
        { batch-number: batch-number }
        {
          total-doses: u0,
          total-reports: u1,
          mild-events: mild-count,
          moderate-events: moderate-count,
          severe-events: severe-count,
          last-updated: block-height
        }
      )
    )
  )
)

(define-private (update-vaccine-safety-stats (vaccine-type (string-ascii 50)) (severity (string-ascii 20)))
  (match (map-get? vaccine-safety-stats { vaccine-type: vaccine-type })
    existing-stats
      (let
        (
          (new-mild (if (is-eq severity "mild") (+ (get mild-events existing-stats) u1) (get mild-events existing-stats)))
          (new-moderate (if (is-eq severity "moderate") (+ (get moderate-events existing-stats) u1) (get moderate-events existing-stats)))
          (new-severe (if (is-eq severity "severe") (+ (get severe-events existing-stats) u1) (get severe-events existing-stats)))
        )
        (map-set vaccine-safety-stats
          { vaccine-type: vaccine-type }
          (merge existing-stats {
            total-reports: (+ (get total-reports existing-stats) u1),
            mild-events: new-mild,
            moderate-events: new-moderate,
            severe-events: new-severe,
            last-updated: block-height
          })
        )
      )
    (let
      (
        (mild-count (if (is-eq severity "mild") u1 u0))
        (moderate-count (if (is-eq severity "moderate") u1 u0))
        (severe-count (if (is-eq severity "severe") u1 u0))
      )
      (map-set vaccine-safety-stats
        { vaccine-type: vaccine-type }
        {
          total-doses: u0,
          total-reports: u1,
          mild-events: mild-count,
          moderate-events: moderate-count,
          severe-events: severe-count,
          last-updated: block-height
        }
      )
    )
  )
)

;; Investigation Management
(define-public (update-investigation-status
  (report-id uint)
  (investigator-id (string-ascii 50))
  (investigation-status (string-ascii 30))
)
  (begin
    (asserts! (is-authorized-reporter investigator-id) ERR-NOT-AUTHORIZED)
    (match (map-get? adverse-event-reports { report-id: report-id })
      report
        (ok (map-set adverse-event-reports
          { report-id: report-id }
          (merge report {
            investigation-status: investigation-status,
            updated-at: block-height
          })
        ))
      ERR-REPORT-NOT-FOUND
    )
  )
)

(define-public (set-follow-up-required
  (report-id uint)
  (investigator-id (string-ascii 50))
  (follow-up-required bool)
)
  (begin
    (asserts! (is-authorized-reporter investigator-id) ERR-NOT-AUTHORIZED)
    (match (map-get? adverse-event-reports { report-id: report-id })
      report
        (ok (map-set adverse-event-reports
          { report-id: report-id }
          (merge report {
            follow-up-required: follow-up-required,
            updated-at: block-height
          })
        ))
      ERR-REPORT-NOT-FOUND
    )
  )
)

;; Query Functions
(define-read-only (get-adverse-event-report (report-id uint))
  (map-get? adverse-event-reports { report-id: report-id })
)

(define-read-only (get-batch-safety-stats (batch-number (string-ascii 20)))
  (map-get? batch-safety-stats { batch-number: batch-number })
)

(define-read-only (get-vaccine-safety-stats (vaccine-type (string-ascii 50)))
  (map-get? vaccine-safety-stats { vaccine-type: vaccine-type })
)

(define-read-only (get-reporter-info (reporter-id (string-ascii 50)))
  (map-get? authorized-reporters { reporter-id: reporter-id })
)

(define-read-only (calculate-adverse-event-rate (batch-number (string-ascii 20)))
  (match (map-get? batch-safety-stats { batch-number: batch-number })
    stats
      (if (> (get total-doses stats) u0)
        (some (/ (* (get total-reports stats) u10000) (get total-doses stats)))
        none
      )
    none
  )
)

(define-read-only (get-total-reports)
  (- (var-get next-report-id) u1)
)

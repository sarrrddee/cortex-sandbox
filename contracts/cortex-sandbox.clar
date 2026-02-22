;; ============================================================
;; Contract: cortex-sandbox.clar
;; Purpose : AI action simulation & approval sandbox
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------

(define-constant ERR-NOT-OWNER      (err u1100))
(define-constant ERR-NOT-FOUND      (err u1101))
(define-constant ERR-ALREADY-DECIDED (err u1102))
(define-constant ERR-NOT-APPROVED   (err u1103))

;; -------------------------
;; CONSTANTS
;; -------------------------

(define-constant contract-owner tx-sender)

;; -------------------------
;; STATE
;; -------------------------

(define-data-var next-action-id uint u0)

;; -------------------------
;; STORAGE
;; -------------------------

(define-map actions
  { id: uint }
  {
    proposer: principal,
    action-type: (string-ascii 32),
    payload-hash: (buff 32),
    approved: bool,
    rejected: bool,
    created-at: uint,
    decided-at: uint
  }
)

;; -------------------------
;; SUBMIT ACTION (AI / AGENT)
;; -------------------------

(define-public (submit-action
  (action-type (string-ascii 32))
  (payload-hash (buff 32))
)
  (let ((id (+ (var-get next-action-id) u1)))
    (map-set actions
      { id: id }
      {
        proposer: tx-sender,
        action-type: action-type,
        payload-hash: payload-hash,
        approved: false,
        rejected: false,
        created-at: u0,
        decided-at: u0
      }
    )

    (var-set next-action-id id)
    (ok id)
  )
)

;; -------------------------
;; APPROVE ACTION (HUMAN / CONTROLLER)
;; -------------------------

(define-public (approve-action (id uint))
  (let ((record (map-get? actions { id: id })))
    (match record data
      (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (asserts! (and (not (get approved data)) (not (get rejected data)))
                  ERR-ALREADY-DECIDED)

        (map-set actions
          { id: id }
          (merge data
            {
              approved: true,
              decided-at: u0
            }
          )
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; REJECT ACTION
;; -------------------------

(define-public (reject-action (id uint))
  (let ((record (map-get? actions { id: id })))
    (match record data
      (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (asserts! (and (not (get approved data)) (not (get rejected data)))
                  ERR-ALREADY-DECIDED)

        (map-set actions
          { id: id }
          (merge data
            {
              rejected: true,
              decided-at: u0
            }
          )
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; CLEAR FOR EXECUTION
;; -------------------------

(define-read-only (is-approved (id uint))
  (let ((record (map-get? actions { id: id })))
    (match record data
      (get approved data)
      false
    )
  )
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (get-action (id uint))
  (map-get? actions { id: id })
)

(define-read-only (action-count)
  (var-get next-action-id)
)

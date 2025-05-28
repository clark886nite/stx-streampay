;; ------------------------------------------------------------
;; Contract: stx-streampay
;; Purpose: Stream STX payments over time from sender to recipient
;; Author: [Your Name]
;; License: MIT
;; ------------------------------------------------------------

(define-constant ERR_STREAM_EXISTS (err u100))
(define-constant ERR_STREAM_NOT_FOUND (err u101))
(define-constant ERR_NOT_RECIPIENT (err u102))
(define-constant ERR_NOT_SENDER (err u103))
(define-constant ERR_TOO_EARLY (err u104))
(define-constant ERR_NO_FUNDS (err u105))

;; Stream data: sender creates a stream to recipient over time
(define-map streams
  uint ;; stream-id
  (tuple
    (sender principal)
    (recipient principal)
    (start-block uint)
    (end-block uint)
    (total-amount uint)
    (withdrawn uint)
  )
)

(define-data-var next-stream-id uint u1)

;; === Create a stream ===
(define-public (create-stream (recipient principal) (duration uint) (total-amount uint))
  (let (
        (sender tx-sender)
        (stream-id (var-get next-stream-id))
        (start stacks-block-height)
        (end (+ stacks-block-height duration))
      )
    (match (stx-transfer? total-amount sender (as-contract tx-sender))
      success
      (begin
        (map-set streams stream-id {
          sender: sender,
          recipient: recipient,
          start-block: start,
          end-block: end,
          total-amount: total-amount,
          withdrawn: u0
        })
        (var-set next-stream-id (+ stream-id u1))
        (ok stream-id)
      )
      error (err error)
    )
  )
)

;; === Withdraw available funds ===
(define-public (withdraw (stream-id uint))
  (let (
        (now stacks-block-height)
        (caller tx-sender)
      )
    (match (map-get? streams stream-id)
      stream
      (if (is-eq caller (get recipient stream))
        (let (
              (start (get start-block stream))
              (end (get end-block stream))
              (total (get total-amount stream))
              (withdrawn (get withdrawn stream))
              (elapsed (if (> now end) (- end start) (- now start)))
              (duration (- end start))
              (claimable (/ (* elapsed total) duration))
              (available (- claimable withdrawn))
            )
          (if (<= available u0)
              ERR_NO_FUNDS
              (begin
                (map-set streams stream-id {
                  sender: (get sender stream),
                  recipient: (get recipient stream),
                  start-block: start,
                  end-block: end,
                  total-amount: total,
                  withdrawn: (+ withdrawn available)
                })
                (stx-transfer? available (as-contract tx-sender) caller)
              )
          )
        )
        ERR_NOT_RECIPIENT
      )
      ERR_STREAM_NOT_FOUND
    )
  )
)

;; === Cancel a stream and refund remaining STX to sender ===
(define-public (cancel-stream (stream-id uint))
  (let ((caller tx-sender))
    (match (map-get? streams stream-id)
      stream
      (if (is-eq caller (get sender stream))
        (let (
              (now stacks-block-height)
              (start (get start-block stream))
              (end (get end-block stream))
              (total (get total-amount stream))
              (withdrawn (get withdrawn stream))
              (elapsed (if (> now end) (- end start) (- now start)))
              (duration (- end start))
              (claimable (/ (* elapsed total) duration))
              (available (- claimable withdrawn))
              (refund (- total claimable))
            )
          (match (stx-transfer? refund (as-contract tx-sender) caller)
            success
            (begin
              (map-delete streams stream-id)
              (ok true)
            )
            error (err error)
          )
        )
        ERR_NOT_SENDER
      )
      ERR_STREAM_NOT_FOUND
    )
  )
)

;; === Read-only: Get stream details ===
(define-read-only (get-stream (stream-id uint))
  (map-get? streams stream-id)
)

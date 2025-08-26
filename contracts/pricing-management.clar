;; Personal Shopping Services - Pricing Management Contract
;; Handles service packages, pricing tiers, and payment processing

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-INVALID-PACKAGE (err u401))
(define-constant ERR-INVALID-PRICE (err u402))
(define-constant ERR-PACKAGE-NOT-FOUND (err u403))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u404))
(define-constant ERR-PAYMENT-FAILED (err u405))
(define-constant ERR-INVALID-DISCOUNT (err u406))
(define-constant ERR-EXPIRED-OFFER (err u407))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Service packages
(define-map service-packages
  { package-id: uint }
  {
    package-name: (string-ascii 50),
    description: (string-ascii 200),
    base-price: uint,
    duration-days: uint,
    included-services: (list 10 (string-ascii 50)),
    max-items: uint,
    max-sessions: uint,
    stylist-commission-rate: uint,
    is-active: bool,
    created-date: uint
  }
)

;; Dynamic pricing factors
(define-map pricing-factors
  { factor-type: (string-ascii 20) }
  {
    base-multiplier: uint,
    experience-bonus: uint,
    demand-multiplier: uint,
    seasonal-adjustment: uint,
    location-premium: uint,
    last-updated: uint
  }
)

;; Stylist pricing tiers
(define-map stylist-pricing-tiers
  { stylist-id: principal }
  {
    tier-level: uint,
    hourly-rate: uint,
    package-multiplier: uint,
    commission-rate: uint,
    premium-services: bool,
    tier-updated: uint
  }
)

;; Payment transactions
(define-map payment-transactions
  { payment-id: uint }
  {
    client-id: principal,
    stylist-id: principal,
    package-id: uint,
    base-amount: uint,
    discount-amount: uint,
    final-amount: uint,
    payment-method: (string-ascii 20),
    payment-status: (string-ascii 20),
    transaction-date: uint,
    service-start-date: uint,
    service-end-date: uint,
    refund-eligible: bool
  }
)

;; Discount codes and promotions
(define-map discount-codes
  { code: (string-ascii 20) }
  {
    discount-type: (string-ascii 10),
    discount-value: uint,
    min-purchase: uint,
    max-uses: uint,
    current-uses: uint,
    valid-from: uint,
    valid-until: uint,
    applicable-packages: (list 5 uint),
    is-active: bool
  }
)

;; Fee distribution settings
(define-map fee-distribution
  { service-type: (string-ascii 20) }
  {
    platform-fee-rate: uint,
    stylist-commission-rate: uint,
    payment-processing-fee: uint,
    insurance-fee: uint,
    marketing-fee: uint
  }
)

;; Counters
(define-data-var next-package-id uint u1)
(define-data-var next-payment-id uint u1)

;; Create service package (admin only)
(define-public (create-service-package
  (package-name (string-ascii 50))
  (description (string-ascii 200))
  (base-price uint)
  (duration-days uint)
  (included-services (list 10 (string-ascii 50)))
  (max-items uint)
  (max-sessions uint)
  (stylist-commission-rate uint)
)
  (let ((package-id (var-get next-package-id)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> base-price u0) ERR-INVALID-PRICE)
    (asserts! (> duration-days u0) ERR-INVALID-PACKAGE)
    (asserts! (<= stylist-commission-rate u100) ERR-INVALID-PRICE)

    (map-set service-packages
      { package-id: package-id }
      {
        package-name: package-name,
        description: description,
        base-price: base-price,
        duration-days: duration-days,
        included-services: included-services,
        max-items: max-items,
        max-sessions: max-sessions,
        stylist-commission-rate: stylist-commission-rate,
        is-active: true,
        created-date: block-height
      }
    )

    (var-set next-package-id (+ package-id u1))
    (ok package-id)
  )
)

;; Set stylist pricing tier
(define-public (set-stylist-pricing-tier
  (stylist-id principal)
  (tier-level uint)
  (hourly-rate uint)
  (package-multiplier uint)
  (commission-rate uint)
  (premium-services bool)
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= tier-level u1) (<= tier-level u5)) ERR-INVALID-PACKAGE)
    (asserts! (> hourly-rate u0) ERR-INVALID-PRICE)
    (asserts! (<= commission-rate u100) ERR-INVALID-PRICE)

    (map-set stylist-pricing-tiers
      { stylist-id: stylist-id }
      {
        tier-level: tier-level,
        hourly-rate: hourly-rate,
        package-multiplier: package-multiplier,
        commission-rate: commission-rate,
        premium-services: premium-services,
        tier-updated: block-height
      }
    )
    (ok true)
  )
)

;; Calculate dynamic price for package
(define-public (calculate-package-price (package-id uint) (stylist-id principal))
  (match (map-get? service-packages { package-id: package-id })
    package-data
    (match (map-get? stylist-pricing-tiers { stylist-id: stylist-id })
      tier-data
      (let (
        (base-price (get base-price package-data))
        (multiplier (get package-multiplier tier-data))
        (final-price (/ (* base-price multiplier) u100))
      )
        (ok final-price)
      )
      (ok (get base-price package-data))
    )
    ERR-PACKAGE-NOT-FOUND
  )
)

;; Process payment for service package
(define-public (process-payment
  (stylist-id principal)
  (package-id uint)
  (discount-code (optional (string-ascii 20)))
  (payment-method (string-ascii 20))
)
  (let (
    (client-id tx-sender)
    (payment-id (var-get next-payment-id))
  )
    (match (map-get? service-packages { package-id: package-id })
      package-data
      (let (
        (base-amount (unwrap! (calculate-package-price package-id stylist-id) ERR-INVALID-PRICE))
        (discount-amount (calculate-discount base-amount discount-code))
        (final-amount (- base-amount discount-amount))
      )
        (asserts! (get is-active package-data) ERR-PACKAGE-NOT-FOUND)

        (map-set payment-transactions
          { payment-id: payment-id }
          {
            client-id: client-id,
            stylist-id: stylist-id,
            package-id: package-id,
            base-amount: base-amount,
            discount-amount: discount-amount,
            final-amount: final-amount,
            payment-method: payment-method,
            payment-status: "completed",
            transaction-date: block-height,
            service-start-date: block-height,
            service-end-date: (+ block-height (* (get duration-days package-data) u144)),
            refund-eligible: true
          }
        )

        ;; Update discount code usage if applicable
        (match discount-code
          code (update-discount-usage code)
          true
        )

        (var-set next-payment-id (+ payment-id u1))
        (ok payment-id)
      )
      ERR-PACKAGE-NOT-FOUND
    )
  )
)

;; Create discount code (admin only)
(define-public (create-discount-code
  (code (string-ascii 20))
  (discount-type (string-ascii 10))
  (discount-value uint)
  (min-purchase uint)
  (max-uses uint)
  (valid-from uint)
  (valid-until uint)
  (applicable-packages (list 5 uint))
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> discount-value u0) ERR-INVALID-DISCOUNT)
    (asserts! (< valid-from valid-until) ERR-INVALID-DISCOUNT)

    (map-set discount-codes
      { code: code }
      {
        discount-type: discount-type,
        discount-value: discount-value,
        min-purchase: min-purchase,
        max-uses: max-uses,
        current-uses: u0,
        valid-from: valid-from,
        valid-until: valid-until,
        applicable-packages: applicable-packages,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Set fee distribution (admin only)
(define-public (set-fee-distribution
  (service-type (string-ascii 20))
  (platform-fee-rate uint)
  (stylist-commission-rate uint)
  (payment-processing-fee uint)
  (insurance-fee uint)
  (marketing-fee uint)
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= (+ platform-fee-rate stylist-commission-rate payment-processing-fee insurance-fee marketing-fee) u100) ERR-INVALID-PRICE)

    (map-set fee-distribution
      { service-type: service-type }
      {
        platform-fee-rate: platform-fee-rate,
        stylist-commission-rate: stylist-commission-rate,
        payment-processing-fee: payment-processing-fee,
        insurance-fee: insurance-fee,
        marketing-fee: marketing-fee
      }
    )
    (ok true)
  )
)

;; Helper function to calculate discount
(define-private (calculate-discount (base-amount uint) (discount-code (optional (string-ascii 20))))
  (match discount-code
    code
    (match (map-get? discount-codes { code: code })
      discount-data
      (if (and
            (get is-active discount-data)
            (>= block-height (get valid-from discount-data))
            (<= block-height (get valid-until discount-data))
            (< (get current-uses discount-data) (get max-uses discount-data))
            (>= base-amount (get min-purchase discount-data))
          )
        (if (is-eq (get discount-type discount-data) "percentage")
          (/ (* base-amount (get discount-value discount-data)) u100)
          (get discount-value discount-data)
        )
        u0
      )
      u0
    )
    u0
  )
)

;; Helper function to update discount usage
(define-private (update-discount-usage (code (string-ascii 20)))
  (match (map-get? discount-codes { code: code })
    discount-data
    (map-set discount-codes
      { code: code }
      (merge discount-data {
        current-uses: (+ (get current-uses discount-data) u1)
      })
    )
    false
  )
)

;; Read-only functions

;; Get service package details
(define-read-only (get-service-package (package-id uint))
  (map-get? service-packages { package-id: package-id })
)

;; Get stylist pricing tier
(define-read-only (get-stylist-pricing-tier (stylist-id principal))
  (map-get? stylist-pricing-tiers { stylist-id: stylist-id })
)

;; Get payment transaction
(define-read-only (get-payment-transaction (payment-id uint))
  (map-get? payment-transactions { payment-id: payment-id })
)

;; Validate discount code
(define-read-only (validate-discount-code (code (string-ascii 20)))
  (match (map-get? discount-codes { code: code })
    discount-data
    (and
      (get is-active discount-data)
      (>= block-height (get valid-from discount-data))
      (<= block-height (get valid-until discount-data))
      (< (get current-uses discount-data) (get max-uses discount-data))
    )
    false
  )
)

;; Get fee distribution for service type
(define-read-only (get-fee-distribution (service-type (string-ascii 20)))
  (map-get? fee-distribution { service-type: service-type })
)

;; Check if package is active
(define-read-only (is-package-active (package-id uint))
  (match (map-get? service-packages { package-id: package-id })
    package-data (get is-active package-data)
    false
  )
)

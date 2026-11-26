package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Payment;
import com.sangam.sangamdairybackend.repository.PaymentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class PaymentController {

    private final PaymentRepository paymentRepository;

    public PaymentController(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    // =========================================================
    // CREATE PAYMENT
    // =========================================================

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Payment createPayment(
            @RequestBody PaymentRequest request
    ) {

        validatePaymentRequest(request);

        // Prevent duplicate payment references.
        if (paymentRepository
                .findByPaymentReference(
                        request.getPaymentReference()
                )
                .isPresent()) {

            throw new IllegalArgumentException(
                    "Payment reference already exists."
            );
        }

        Payment payment = new Payment();

        payment.setOrderKey(
                request.getOrderKey()
        );

        payment.setPaymentReference(
                request.getPaymentReference()
        );

        payment.setAmount(
                request.getAmount()
        );

        payment.setPaymentMethod(
                request.getPaymentMethod()
        );

        // New payment always starts as PENDING.
        payment.setStatus("PENDING");

        payment.setCreatedAt(
                LocalDateTime.now()
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        return paymentRepository.save(payment);
    }

    // =========================================================
    // GET PAYMENT BY REFERENCE
    // =========================================================

    @GetMapping("/{paymentReference}")
    public Payment getPayment(
            @PathVariable String paymentReference
    ) {

        return paymentRepository
                .findByPaymentReference(paymentReference)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Payment not found."
                        )
                );
    }

    // =========================================================
    // GET ALL PAYMENTS FOR ORDER KEY
    // =========================================================

    @GetMapping("/order/{orderKey}")
    public List<Payment> getPaymentsByOrderKey(
            @PathVariable String orderKey
    ) {

        return paymentRepository.findByOrderKey(orderKey);
    }

    // =========================================================
    // MARK PAYMENT AS SUCCESS
    // =========================================================

    @PostMapping("/{paymentReference}/success")
    public Payment markPaymentSuccess(
            @PathVariable String paymentReference,
            @RequestBody PaymentSuccessRequest request
    ) {

        Payment payment = paymentRepository
                .findByPaymentReference(paymentReference)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Payment not found."
                        )
                );

        // Payment must be pending before success.
        if (!"PENDING".equalsIgnoreCase(
                payment.getStatus()
        )) {

            throw new IllegalStateException(
                    "Only PENDING payments can be marked as SUCCESS."
            );
        }

        String transactionId =
                request.getTransactionId();

        if (transactionId == null
                || transactionId.isBlank()) {

            transactionId =
                    "TEST-TXN-"
                            + System.currentTimeMillis();
        }

        payment.setStatus("SUCCESS");

        payment.setTransactionId(
                transactionId
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        return paymentRepository.save(payment);
    }

    // =========================================================
    // MARK PAYMENT AS FAILED
    // =========================================================

    @PostMapping("/{paymentReference}/failed")
    public Payment markPaymentFailed(
            @PathVariable String paymentReference,
            @RequestBody(required = false)
            PaymentFailureRequest request
    ) {

        Payment payment = paymentRepository
                .findByPaymentReference(paymentReference)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Payment not found."
                        )
                );

        if (!"PENDING".equalsIgnoreCase(
                payment.getStatus()
        )) {

            throw new IllegalStateException(
                    "Only PENDING payments can be marked as FAILED."
            );
        }

        payment.setStatus("FAILED");

        if (request != null
                && request.getTransactionId() != null
                && !request.getTransactionId().isBlank()) {

            payment.setTransactionId(
                    request.getTransactionId()
            );
        }

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        return paymentRepository.save(payment);
    }

    // =========================================================
    // VALIDATE PAYMENT REQUEST
    // =========================================================

    private void validatePaymentRequest(
            PaymentRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Payment request is required."
            );
        }

        if (request.getOrderKey() == null
                || request.getOrderKey().isBlank()) {

            throw new IllegalArgumentException(
                    "Order key is required."
            );
        }

        if (request.getPaymentReference() == null
                || request.getPaymentReference().isBlank()) {

            throw new IllegalArgumentException(
                    "Payment reference is required."
            );
        }

        if (request.getAmount() == null
                || request.getAmount().compareTo(
                BigDecimal.ZERO
        ) <= 0) {

            throw new IllegalArgumentException(
                    "Payment amount must be greater than zero."
            );
        }

        if (request.getPaymentMethod() == null
                || request.getPaymentMethod().isBlank()) {

            throw new IllegalArgumentException(
                    "Payment method is required."
            );
        }
    }

    // =========================================================
    // PAYMENT REQUEST
    // =========================================================

    public static class PaymentRequest {

        private String orderKey;
        private String paymentReference;
        private BigDecimal amount;
        private String paymentMethod;

        public PaymentRequest() {
        }

        public String getOrderKey() {
            return orderKey;
        }

        public void setOrderKey(
                String orderKey
        ) {
            this.orderKey = orderKey;
        }

        public String getPaymentReference() {
            return paymentReference;
        }

        public void setPaymentReference(
                String paymentReference
        ) {
            this.paymentReference =
                    paymentReference;
        }

        public BigDecimal getAmount() {
            return amount;
        }

        public void setAmount(
                BigDecimal amount
        ) {
            this.amount = amount;
        }

        public String getPaymentMethod() {
            return paymentMethod;
        }

        public void setPaymentMethod(
                String paymentMethod
        ) {
            this.paymentMethod =
                    paymentMethod;
        }
    }

    // =========================================================
    // PAYMENT SUCCESS REQUEST
    // =========================================================

    public static class PaymentSuccessRequest {

        private String transactionId;

        public PaymentSuccessRequest() {
        }

        public String getTransactionId() {
            return transactionId;
        }

        public void setTransactionId(
                String transactionId
        ) {
            this.transactionId =
                    transactionId;
        }
    }

    // =========================================================
    // PAYMENT FAILURE REQUEST
    // =========================================================

    public static class PaymentFailureRequest {

        private String transactionId;

        public PaymentFailureRequest() {
        }

        public String getTransactionId() {
            return transactionId;
        }

        public void setTransactionId(
                String transactionId
        ) {
            this.transactionId =
                    transactionId;
        }
    }
}

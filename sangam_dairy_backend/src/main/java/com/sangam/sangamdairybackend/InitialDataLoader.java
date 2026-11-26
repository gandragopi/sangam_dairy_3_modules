package com.sangam.sangamdairybackend;

import com.sangam.sangamdairybackend.entity.*;
import com.sangam.sangamdairybackend.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Component
public class InitialDataLoader implements CommandLineRunner {

    private final CustomerRepository customerRepository;
    private final AddressRepository addressRepository;
    private final OfferRepository offerRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final NotificationRepository notificationRepository;
    private final BannerRepository bannerRepository;
    private final OrderRepository orderRepository;
    private final SupportTicketRepository supportTicketRepository;

    public InitialDataLoader(
            CustomerRepository customerRepository,
            AddressRepository addressRepository,
            OfferRepository offerRepository,
            SubscriptionRepository subscriptionRepository,
            WalletTransactionRepository walletTransactionRepository,
            NotificationRepository notificationRepository,
            BannerRepository bannerRepository,
            OrderRepository orderRepository,
            SupportTicketRepository supportTicketRepository
    ) {
        this.customerRepository = customerRepository;
        this.addressRepository = addressRepository;
        this.offerRepository = offerRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.notificationRepository = notificationRepository;
        this.bannerRepository = bannerRepository;
        this.orderRepository = orderRepository;
        this.supportTicketRepository = supportTicketRepository;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        String testPhone = "9390736087";

        // 1. Seed Customer
        if (customerRepository.findByPhone(testPhone).isEmpty()) {
            Customer customer = new Customer();
            customer.setId("CUST-1001");
            customer.setName("Gandra Gopi");
            customer.setEmail("gandragopigandra123@gmail.com");
            customer.setPhone(testPhone);
            customer.setCity("Hyderabad");
            customer.setPassword("Gandra@2003");
            customer.setTotalOrders(5);
            customer.setTotalSpent(1250.0);
            customer.setJoinedDate(LocalDateTime.now().minusDays(30));
            customer.setActive(true);
            customerRepository.save(customer);
        }

        // 2. Seed Address
        if (addressRepository.findByCustomerKey(testPhone).isEmpty()) {
            Address address = new Address();
            address.setCustomerKey(testPhone);
            address.setFullName("Gandra Gopi");
            address.setPhone(testPhone);
            address.setAddressLine("Flat 202, Sunshine Apartments, Main Road");
            address.setCity("Hyderabad");
            address.setPincode("500081");
            address.setDefaultAddress(true);
            addressRepository.save(address);
        }

        // 3. Seed Banners
        if (bannerRepository.count() == 0) {
            Banner b1 = new Banner();
            b1.setId("BAN-101");
            b1.setTitle("Pure & Fresh Cow Milk");
            b1.setSubtitle("Delivered straight from farm to doorstep daily");
            b1.setTag("Fresh & Pure");
            b1.setImageUrl("https://images.unsplash.com/photo-1550583724-b2692b85b150");
            b1.setActive(true);
            bannerRepository.save(b1);

            Banner b2 = new Banner();
            b2.setId("BAN-102");
            b2.setTitle("Organic Dairy Products");
            b2.setSubtitle("Get 10% instant discount on monthly subscriptions");
            b2.setTag("Special Offer");
            b2.setImageUrl("https://images.unsplash.com/photo-1628088062854-d1870b4553da");
            b2.setActive(true);
            bannerRepository.save(b2);
        }

        // 4. Seed Orders
        if (orderRepository.count() == 0) {
            Order o1 = new Order();
            o1.setId("ORD-1001");
            o1.setCustomerName("Gandra Gopi");
            o1.setCustomerPhone("9390736087");
            o1.setDeliveryAddress("Flat 202, Sunshine Apartments, Hyderabad");
            o1.setTotalAmount(350.0);
            o1.setStatus("DELIVERED");
            o1.setPaymentStatus("PAID");
            o1.setPaymentMethod("UPI");
            o1.setTransactionId("TXN987654321");
            o1.setCreatedAt(LocalDateTime.now().minusDays(2));
            orderRepository.save(o1);

            Order o2 = new Order();
            o2.setId("ORD-1002");
            o2.setCustomerName("Rajesh Kumar");
            o2.setCustomerPhone("9876543210");
            o2.setDeliveryAddress("House No 45, Jubilee Hills, Hyderabad");
            o2.setTotalAmount(520.0);
            o2.setStatus("PLACED");
            o2.setPaymentStatus("PAID");
            o2.setPaymentMethod("CREDIT_CARD");
            o2.setTransactionId("TXN123456789");
            o2.setCreatedAt(LocalDateTime.now().minusHours(3));
            orderRepository.save(o2);
        }

        // 5. Seed Support Tickets
        if (supportTicketRepository.count() == 0) {
            SupportTicket t1 = new SupportTicket();
            t1.setCategory("Delivery");
            t1.setSubject("Delayed morning delivery");
            t1.setDescription("My milk order was delivered 45 minutes past the expected time.");
            t1.setCreatedAt(LocalDateTime.now().minusDays(1));
            supportTicketRepository.save(t1);
        }

        // 6. Seed Offers
        if (offerRepository.count() == 0) {
            Offer offer1 = new Offer();
            offer1.setCode("SANGAM50");
            offer1.setTitle("Flat ₹50 OFF");
            offer1.setDescription("Get flat ₹50 off on orders above ₹300");
            offer1.setDiscountAmount(BigDecimal.valueOf(50));
            offer1.setMinOrderValue(BigDecimal.valueOf(300));
            offer1.setActive(true);
            offerRepository.save(offer1);
        }

        // 7. Seed Subscriptions
        if (subscriptionRepository.findByCustomerKey(testPhone).isEmpty()) {
            Subscription sub = new Subscription();
            sub.setCustomerKey(testPhone);
            sub.setProductId(1L);
            sub.setProductName("Sangam Fresh Cow Milk 500ml");
            sub.setQuantity(2);
            sub.setFrequency("DAILY");
            sub.setPrice(BigDecimal.valueOf(30));
            sub.setStatus("ACTIVE");
            sub.setStartDate(LocalDateTime.now());
            subscriptionRepository.save(sub);
        }

        // 8. Seed Wallet
        if (walletTransactionRepository.findByCustomerKey(testPhone).isEmpty()) {
            WalletTransaction tx = new WalletTransaction();
            tx.setCustomerKey(testPhone);
            tx.setAmount(BigDecimal.valueOf(100));
            tx.setType("CREDIT");
            tx.setDescription("Welcome Bonus Wallet Credit");
            tx.setLoyaltyPoints(50);
            walletTransactionRepository.save(tx);
        }

        // 9. Seed Notifications
        if (notificationRepository.findByCustomerKey(testPhone).isEmpty()) {
            Notification notif = new Notification();
            notif.setCustomerKey(testPhone);
            notif.setTitle("Welcome to Sangam Dairy!");
            notif.setMessage("Thank you for registering. Enjoy farm-fresh pure dairy products delivered daily.");
            notif.setReadStatus(false);
            notificationRepository.save(notif);
        }
    }
}

package com.sangam.sangamdairybackend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sangam.sangamdairybackend.entity.Product;
import com.sangam.sangamdairybackend.repository.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStream;
import java.util.*;

@Component
public class ProductDataLoader implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final ObjectMapper objectMapper;

    public ProductDataLoader(
            ProductRepository productRepository,
            ObjectMapper objectMapper) {
        this.productRepository = productRepository;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {

        // 1. Cleanup any existing duplicate products in DB
        cleanupDuplicateProducts();

        // 2. Load products from products.json if missing
        ClassPathResource resource =
                new ClassPathResource("products.json");

        if (!resource.exists()) {
            return;
        }

        try (InputStream inputStream = resource.getInputStream()) {

            JsonNode products = objectMapper.readTree(inputStream);

            if (!products.isArray()) {
                return;
            }

            int inserted = 0;
            int skipped = 0;

            for (JsonNode item : products) {

                String name = text(item, "name");
                String category = text(item, "category");

                if (name == null || category == null
                        || !item.hasNonNull("price")) {
                    continue;
                }

                // Check by name (case-insensitive) to avoid duplicates if category was updated in Admin Portal
                if (productRepository.existsByNameIgnoreCase(name.trim())) {
                    skipped++;
                    continue;
                }

                Product product = new Product();

                product.setName(name.trim());
                product.setCategory(category.trim());
                product.setImage(text(item, "image"));
                product.setPrice(item.get("price").asDouble());
                product.setPackSize(text(item, "packSize"));
                product.setFat(text(item, "fat"));

                String snf = text(item, "snf");
                if (snf == null) {
                    snf = text(item, "MSNF min");
                }
                product.setSnf(snf);

                product.setShelfLife(text(item, "shelfLife"));
                product.setStorage(text(item, "storage"));
                product.setDescription(text(item, "description"));
                product.setStockQuantity(100);

                JsonNode variants = item.get("variants");
                if (variants != null && !variants.isNull()) {
                    product.setVariants(
                            objectMapper.writeValueAsString(variants));
                }

                product.setActive(true);
                productRepository.save(product);
                inserted++;
            }

            System.out.println(
                    "Product import complete. Inserted: " + inserted
                            + ", skipped existing: " + skipped);
        }
    }

    private void cleanupDuplicateProducts() {
        List<Product> allProducts = productRepository.findAll();
        Set<String> seenNames = new HashSet<>();
        List<Product> duplicatesToRemove = new ArrayList<>();

        for (Product p : allProducts) {
            if (p.getName() == null || p.getName().trim().isEmpty()) {
                continue;
            }
            String key = p.getName().trim().toLowerCase();
            if (seenNames.contains(key)) {
                duplicatesToRemove.add(p);
            } else {
                seenNames.add(key);
            }
        }

        if (!duplicatesToRemove.isEmpty()) {
            productRepository.deleteAll(duplicatesToRemove);
            System.out.println("Cleaned up " + duplicatesToRemove.size() + " duplicate products from database.");
        }
    }

    private String text(JsonNode node, String field) {
        JsonNode value = node.get(field);

        if (value == null || value.isNull()) {
            return null;
        }

        String result = value.asText();
        return result.isBlank() ? null : result;
    }
}

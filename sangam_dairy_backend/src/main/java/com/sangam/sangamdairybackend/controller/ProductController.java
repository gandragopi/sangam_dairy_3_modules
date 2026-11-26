package com.sangam.sangamdairybackend.controller;

import com.sangam.sangamdairybackend.entity.Product;
import com.sangam.sangamdairybackend.repository.ProductRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
@SuppressWarnings("all")
public class ProductController {

    private final ProductRepository productRepository;

    public ProductController(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @GetMapping({"", "/"})
    public List<Product> getProducts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Boolean activeOnly,
            @RequestParam(required = false) Boolean all
    ) {
        if (category != null && !category.trim().isEmpty()) {
            return productRepository.findByCategoryAndActiveTrue(category.trim());
        }
        if (Boolean.TRUE.equals(all) || Boolean.FALSE.equals(activeOnly)) {
            return productRepository.findAll();
        }
        if (active != null) {
            return active ? productRepository.findActiveProducts() : productRepository.findByActiveFalse();
        }
        // Default behavior for customer app: return active products
        return productRepository.findActiveProducts();
    }

    @GetMapping("/all")
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @GetMapping("/admin")
    public List<Product> getAdminProducts() {
        return productRepository.findAll();
    }

    @GetMapping("/active")
    public List<Product> getActiveProducts() {
        return productRepository.findActiveProducts();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/category/{category}")
    public List<Product> getProductsByCategory(@PathVariable String category) {
        return productRepository.findByCategoryAndActiveTrue(category);
    }

    @PostMapping
    public Product createProduct(@RequestBody Product product) {
        if (product.getActive() == null) {
            product.setActive(true);
        }
        if (product.getStockQuantity() == null) {
            product.setStockQuantity(100);
        }
        return productRepository.save(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        return productRepository.findById(id)
                .map(existingProduct -> {
                    if (productDetails.getName() != null) existingProduct.setName(productDetails.getName());
                    if (productDetails.getCategory() != null) existingProduct.setCategory(productDetails.getCategory());
                    if (productDetails.getPackSize() != null) existingProduct.setPackSize(productDetails.getPackSize());
                    if (productDetails.getPrice() != null) existingProduct.setPrice(productDetails.getPrice());
                    if (productDetails.getStockQuantity() != null) existingProduct.setStockQuantity(productDetails.getStockQuantity());
                    if (productDetails.getActive() != null) existingProduct.setActive(productDetails.getActive());
                    if (productDetails.getDescription() != null) existingProduct.setDescription(productDetails.getDescription());
                    if (productDetails.getImage() != null) existingProduct.setImage(productDetails.getImage());
                    return ResponseEntity.ok(productRepository.save(existingProduct));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}

package br.com.hematsu.lance_certo.repository.specs;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import br.com.hematsu.lance_certo.model.Product;

public class ProductSpecifications {

    private ProductSpecifications() {
    }

    public static Specification<Product> nameLike(String name) {
        return (root, query, criteriaBuilder) -> criteriaBuilder
                .like(criteriaBuilder
                        .lower(root.get("name")), "%" + name.toLowerCase() + "%");
    }

    public static Specification<Product> categoryIn(List<String> categories) {
        return (root, query, criteriaBuilder) -> {
            if (categories == null || categories.isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            return root.get("category").in(categories);
        };

    }

    public static Specification<Product> withFilters(String name, List<String> categories) {

        List<Specification<Product>> specs = new ArrayList<>();

        if (name != null) {
            specs.add(nameLike(name));
        }
        if (categories.isEmpty()) {
            specs.add(categoryIn(categories));
        }

        return Specification.allOf(specs);
    }
}

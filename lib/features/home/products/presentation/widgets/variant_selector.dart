import 'package:flutter/material.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';

class VariantSelector extends StatelessWidget {
  final Product product;
  final ProductVariant? selectedVariant;
  final Function(ProductVariant) onVariantSelected;
  final bool compact;

  const VariantSelector({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.onVariantSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (product.variants.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            'Options',
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.variants.map((variant) {
            final isSelected = selectedVariant?.id == variant.id;
            final isAvailable = variant.available;
            
            return GestureDetector(
              onTap: isAvailable 
                ? () => onVariantSelected(variant)
                : null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : (isAvailable ? Colors.white : Colors.grey.shade100),
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : (isAvailable ? Colors.grey.shade300 : Colors.grey.shade200),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  variant.title,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : (isAvailable ? Colors.black : Colors.grey),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: compact ? 12 : 14,
                    decoration: isAvailable ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!compact && product.variants.any((v) => !v.available)) ...[
          const SizedBox(height: 4),
          Text(
            'Some options are out of stock',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

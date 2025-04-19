part of 'product_selection_cubit.dart';

class ProductSelectionState extends Equatable {
  final ProductVariant? selectedVariant;
  final int quantity;

  const ProductSelectionState({
    required this.selectedVariant,
    required this.quantity,
  });

  ProductSelectionState copyWith({
    ProductVariant? selectedVariant,
    int? quantity,
  }) {
    return ProductSelectionState(
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [selectedVariant, quantity];
}

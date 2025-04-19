import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/model/product.dart';

part 'product_selection_state.dart';

class ProductSelectionCubit extends Cubit<ProductSelectionState> {
  ProductSelectionCubit({required ProductVariant? initialVariant})
      : super(ProductSelectionState(
          selectedVariant: initialVariant,
          quantity: 1,
        ));

  void selectVariant(ProductVariant variant) {
    emit(state.copyWith(selectedVariant: variant, quantity: 1));
  }

  void setQuantity(int quantity) {
    emit(state.copyWith(quantity: quantity));
  }

  void reset(ProductVariant? variant) {
    emit(ProductSelectionState(
      selectedVariant: variant,
      quantity: 1,
    ));
  }
}

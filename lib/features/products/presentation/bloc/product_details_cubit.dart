import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/features/products/domain/usecases/get_product_by_id.dart';
import 'package:ecom/features/products/presentation/bloc/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductById getProductById;

  ProductDetailsCubit(this.getProductById) : super(const ProductDetailsState());

  Future<void> load(int id) async {
    emit(const ProductDetailsState(status: ProductDetailsStatus.loading));
    final result = await getProductById(GetProductByIdParams(id));
    result.when(
      ok: (product) => emit(
        ProductDetailsState(
          status: ProductDetailsStatus.success,
          product: product,
        ),
      ),
      err: (failure) => emit(
        ProductDetailsState(
          status: ProductDetailsStatus.failure,
          failure: failure,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/product_model.dart';
import '../product_repos/product_repos.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepos _productRepos;
  StreamSubscription? _productSubscription;
  ProductBloc({required ProductRepos productRepos})
      : _productRepos = productRepos,
        super(ProductLoading()) {
    on<LoadProducts>(_mapLoadProductsToState);
    on<UpdateProducts>(_mapUpdateProductsToState);
    on<AddProduct>(_mapAddProductToState);
  }

  FutureOr<void> _mapUpdateProductsToState(
      UpdateProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoaded(products: event.products));
  }

  FutureOr<void> _mapLoadProductsToState(
      LoadProducts event, Emitter<ProductState> emit) async {
    _productSubscription?.cancel();
    _productSubscription = _productRepos.getAllProducts().listen(
      (products) {
        add(
          UpdateProducts(products),
        );
      },
    );
  }
  FutureOr<void> _mapAddProductToState(
      AddProduct event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      emit(ProductAdding());
      await _productRepos.addProduct(event.product);
      emit(ProductAdded());
    } catch (e) {
      emit(ProductAddError(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}

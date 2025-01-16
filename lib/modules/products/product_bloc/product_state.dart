part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded({this.products = const <Product>[]});

  @override
  List<Object> get props => [products];
}

class ProductAdding extends ProductState {}

class ProductAdded extends ProductState {}

class ProductAddError extends ProductState {
  final String error;

  const ProductAddError({required this.error});

  @override
  List<Object> get props => [error];
}

import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class GetCategories implements UseCase<List<String>, NoParams> {
  final ProductsRepository repository;

  const GetCategories(this.repository);

  @override
  Future<Result<List<String>>> call(NoParams params) {
    return repository.getCategories();
  }
}

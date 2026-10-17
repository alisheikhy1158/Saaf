// Covers: product codes from the camera — ordinary barcodes, QR codes that
// carry the product number (GS1 Digital Link, GS1 DataMatrix) and QR codes
// that only hold a link or text (looked up by the AI instead)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/usecases/read_product_code.dart';

void main() {
  const read = ReadProductCode();

  test('an ordinary barcode number', () {
    expect(read('3337875743563'), const ProductBarcode('3337875743563'));
    expect(read(' 12345670 '), const ProductBarcode('12345670'));
  });

  test('a GS1 Digital Link QR code gives its product number', () {
    expect(
      read('https://id.gs1.org/01/03337875743563/10/ABC123'),
      const ProductBarcode('3337875743563'),
    );
    expect(
      read('https://brand.example.com/products/01/9506000134352?11=221231'),
      const ProductBarcode('9506000134352'),
    );
  });

  test('a GS1 element string or DataMatrix gives its product number', () {
    expect(
      read('(01)03337875743563(17)271231'),
      const ProductBarcode('3337875743563'),
    );
    expect(
      read('\u001d0103337875743563172712311012AB'),
      const ProductBarcode('3337875743563'),
    );
  });

  test('a 14-digit number keeps its leading digit when it is not 0', () {
    expect(read('13337875743560'), const ProductBarcode('13337875743560'));
  });

  test('any other QR code is text for the AI look-up', () {
    expect(
      read('https://www.brand.pk/neem-face-wash'),
      const ProductQrText('https://www.brand.pk/neem-face-wash'),
    );
    expect(read('Batch 42'), const ProductQrText('Batch 42'));
  });

  test('very long QR text is cut short', () {
    final code = read('x' * 900);
    expect(code, isA<ProductQrText>());
    expect((code! as ProductQrText).text.length, ReadProductCode.maxText);
  });

  test('nothing readable gives nothing', () {
    expect(read(''), isNull);
    expect(read('   '), isNull);
  });
}

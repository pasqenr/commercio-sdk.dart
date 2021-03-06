import 'package:commerciosdk/export.dart';
import 'package:meta/meta.dart';

/// Allows to easily create a CommercioDoc and perform common related operations
class CommercioDocHelper {
  /// Creates a CommercioDoc from the given [wallet],
  /// [recipients], [id], [metadata]
  /// and optionally [contentUri], [checksum],
  /// [doSign], [encryptedData], [aesKey].
  static Future<CommercioDoc> fromWallet({
    @required Wallet wallet,
    @required List<String> recipients,
    @required String id,
    @required CommercioDocMetadata metadata,
    String contentUri,
    CommercioDocChecksum checksum,
    CommercioDoSign doSign,
    List<EncryptedData> encryptedData,
    Key aesKey,
  }) async {
    // Build a commercio document
    CommercioDoc commercioDocument = CommercioDoc(
      senderDid: wallet.bech32Address,
      recipientDids: recipients,
      uuid: id,
      contentUri: contentUri,
      metadata: metadata,
      checksum: checksum,
      encryptionData: null,
      doSign: doSign,
    );

    // Encrypt its contents, if necessary
    if (encryptedData != null && encryptedData.isNotEmpty) {
      // Get a default aes key for encryption if needed
      final key = aesKey != null ? aesKey : await KeysHelper.generateAesKey();

      commercioDocument = await encryptField(
        commercioDocument,
        key,
        encryptedData,
        recipients,
        wallet,
      );
    }

    return commercioDocument;
  }
}

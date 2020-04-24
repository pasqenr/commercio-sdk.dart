import 'package:commerciosdk/export.dart';
import 'package:hex/hex.dart';
import 'package:sacco/sacco.dart';
import 'package:sacco/utils/bech32_encoder.dart';

/// Allows to easily create a Did Document and perform common related operations
class DidDocumentHelper {
  /// Creates a Did Document from the given [wallet] and optional [pubKeys].
  static DidDocument fromWallet(Wallet wallet, List<PublicKey> pubKeys) {
    final prefix = "did:com:pub";
    final keyType = [235, 90, 233, 135, 33]; // "addwnpep"
    final fullPublicKey = Uint8List.fromList(keyType + wallet.publicKey);

    final firstKey = DidDocumentPublicKey(
      id: '${wallet.bech32Address}#keys-1',
      type: DidDocumentPubKeyType.RSA,
      controller: wallet.bech32Address,
      publicKeyPem: HEX.encode(fullPublicKey),
    );
    final secondKey = DidDocumentPublicKey(
      id: '${wallet.bech32Address}#keys-2',
      type: DidDocumentPubKeyType.RSA_SIG,
      controller: wallet.bech32Address,
      publicKeyPem: HEX.encode(fullPublicKey),
    );

    pubKeys = pubKeys ?? [];
    final otherKeys = mapIndexed(
            pubKeys, (index, item) => _convertKey(item, index + 2, wallet))
        .toList();

    final verificationMethod = Bech32Encoder.encode(prefix, fullPublicKey);

    final proofContent = DidDocumentProofSignatureContent(
      context: "https://www.w3.org/ns/did/v1",
      id: wallet.bech32Address,
      publicKeys: [firstKey, secondKey] + otherKeys,
    );

    final proof = _computeProof(
        proofContent.id, verificationMethod, proofContent, wallet);

    return DidDocument(
      context: proofContent.context,
      id: proofContent.id,
      publicKeys: proofContent.publicKeys,
      proof: proof,
      services: null,
    );
  }

  /// Converts the given [pubKey] into a [DidDocumentPublicKey] placed at position [index],
  /// [wallet] used to get the controller field of each [DidDocumentPublicKey].
  static DidDocumentPublicKey _convertKey(
      PublicKey pubKey, int index, Wallet wallet) {
    var keyType;
    if (pubKey is RSAPublicKey) {
      keyType = DidDocumentPubKeyType.RSA;
    } else if (pubKey is ECPublicKey) {
      keyType = DidDocumentPubKeyType.SECP256K1;
    } else if (pubKey is Ed25519PublicKey) {
      keyType = DidDocumentPubKeyType.ED25519;
    }

    return DidDocumentPublicKey(
      id: '${wallet.bech32Address}#keys-$index',
      type: keyType,
      controller: wallet.bech32Address,
      publicKeyPem: HEX.encode(pubKey.getEncoded()),
    );
  }

  /// Computes the [DidDocumentProof] based on the given [controller], [verificationMethod] and [proofSignatureContent]
  static DidDocumentProof _computeProof(
    String controller,
    String verificationMethod,
    DidDocumentProofSignatureContent proofSignatureContent,
    Wallet wallet, {
    String proofPurpose,
  }) {
    proofPurpose = proofPurpose ?? "authentication";

    return DidDocumentProof(
      type: "EcdsaSecp256k1VerificationKey2019",
      iso8601creationTimestamp: getTimeStamp(),
      proofPurpose: proofPurpose,
      controller: controller,
      verificationMethod: verificationMethod,
      signatureValue: HEX.encode(
        SignHelper.signSorted(proofSignatureContent.toJson(), wallet),
      ),
    );
  }
}

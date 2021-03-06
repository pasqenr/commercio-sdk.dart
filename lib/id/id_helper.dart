import 'dart:convert';

import 'package:commerciosdk/export.dart';
import 'package:sacco/sacco.dart';
import 'package:uuid/uuid.dart';

/// Allows to perform common operations related to CommercioID.
class IdHelper {
  /// Returns the Did Document associated with the given [did],
  /// or `null` if no Did Document was found.
  static Future<DidDocument> getDidDocument(String did, Wallet wallet) async {
    final url = "${wallet.networkInfo.lcdUrl}/identities/${did}";
    final response = await Network.queryChain(url);
    if (response == null) {
      return null;
    }

    return DidDocument.fromJson(response["did_document"]);
  }

  /// Performs a transaction setting the specified [didDocument] as being
  /// associated with the address present inside the specified [wallet].
  /// Optionally [fee] and broadcasting [mode] parameters can be specified.
  static Future<TransactionResult> setDidDocument(
    DidDocument didDocument,
    Wallet wallet, {
    StdFee fee,
    BroadcastingMode mode,
  }) {
    final msg = MsgSetDidDocument(didDocument: didDocument);
    return TxHelper.createSignAndSendTx(
      [msg],
      wallet,
      fee: fee,
      mode: mode,
    );
  }

  /// Performs a transaction setting the [didDocuments] list as being
  /// associated with the address present inside the specified [wallet].
  /// Optionally [fee] and broadcasting [mode] parameters can be specified.
  static Future<TransactionResult> setDidDocumentsList(
    List<DidDocument> didDocuments,
    Wallet wallet, {
    StdFee fee,
    BroadcastingMode mode,
  }) {
    final msgs = didDocuments
        .map(
          (didDocument) => MsgSetDidDocument(didDocument: didDocument),
        )
        .toList();
    return TxHelper.createSignAndSendTx(
      msgs,
      wallet,
      fee: fee,
      mode: mode,
    );
  }

  /// Creates a new Did power up request from [senderWallet] address for the
  /// given [pairwiseDid] and of the given [amount].
  /// Signs everything that needs to be signed (i.e. the signature JSON inside
  /// the payload) with the private key contained inside the given
  /// [senderWallet] and the [privateKey].
  /// Optionally [fee] and broadcasting [mode] parameters can be specified.
  static Future<TransactionResult> requestDidPowerUp(
    Wallet senderWallet,
    String pairwiseDid,
    List<StdCoin> amount,
    RSAPrivateKey privateKey, {
    StdFee fee,
    BroadcastingMode mode,
  }) async {
    // Build the RequestDidPowerUp
    final RequestDidPowerUp requestDidPowerUp =
        await RequestDidPowerUpHelper.fromWallet(
      senderWallet,
      pairwiseDid,
      amount,
      privateKey,
    );

    // Build the message and send the tx
    final msg = MsgRequestDidPowerUp(
      requestDidPowerUp: requestDidPowerUp,
    );

    return TxHelper.createSignAndSendTx(
      [msg],
      senderWallet,
      fee: fee,
      mode: mode,
    );
  }

  /// Sends a new transaction from the sender [wallet]
  /// to request a list of Did PowerUp [requestDidPowerUpsList].
  /// Optionally [fee] and broadcasting [mode] parameters can be specified.
  static Future<TransactionResult> requestDidPowerUpsList(
    List<RequestDidPowerUp> requestDidPowerUpsList,
    Wallet wallet, {
    StdFee fee,
    BroadcastingMode mode,
  }) {
    final msgs = requestDidPowerUpsList
        .map(
          (requestDidPowerUp) =>
              MsgRequestDidPowerUp(requestDidPowerUp: requestDidPowerUp),
        )
        .toList();
    return TxHelper.createSignAndSendTx(
      msgs,
      wallet,
      fee: fee,
      mode: mode,
    );
  }
}

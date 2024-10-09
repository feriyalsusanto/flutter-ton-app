import 'dart:convert';
import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:ton_miniapp/model.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/js_util.dart';

@JS()
external String connectTonWallet();

@JS()
external disconnectTonWallet();

@JS()
external deposit(String senderAddress, String destinationAddress,
    String amountInTon, String comment, bool useTon);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TelegramWebApp telegram = TelegramWebApp.instance;

  String telegramId = "";
  String walletAddress = "";
  String walletImage = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        // Fetch Telegram ID from Telegram Web App context
        if (telegram.isSupported) {
          telegramId = telegram.initData.user.id.toString();
        }
      } catch (e) {
        //
      }

      // fetch connected wallet
      final jsonWallet = getFromLocalStorage("CONNECTED_WALLET");
      if (jsonWallet != null && jsonWallet.isNotEmpty) {
        final wallet = RemoteMobileNode.fromJson(json.decode(jsonWallet));
        setState(() {
          final walletAddressHex = wallet.account?.address ?? "";
          final parts = walletAddressHex.split(":");
          if (parts.length > 1) {
            walletAddress = TonAddress.fromBytes(
              int.tryParse(parts[0]) ?? 0,
              hex.decode(parts[1]),
              bounceable: false,
              testNet: true,
            ).toFriendlyAddress();
          } else {
            walletAddress = walletAddressHex;
          }
          walletImage = wallet.imageUrl ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(
          'Flutter Web App',
          style: ShadTheme.of(context).textTheme.h4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Row(),
            const SizedBox(height: 20),
            if (walletAddress.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      walletImage,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Your TON Address:",
                    style: ShadTheme.of(context).textTheme.small,
                  ),
                ],
              ),
              SelectableText(
                walletAddress,
                style: ShadTheme.of(context)
                    .textTheme
                    .p
                    .copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // _buildDepositButton(),
              const SizedBox(height: 20),
              ShadButton.outline(
                onPressed: _onDisconnect,
                width: 200,
                icon: const Icon(Icons.link_off_sharp),
                child: const Text('Disconnect Wallet'),
              ),
            ] else
              ShadButton(
                width: 200,
                onPressed: _onConnect,
                icon: const Icon(Icons.wallet),
                child: const Text('Connect Wallet'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onConnect() async {
    try {
      final jsonWallet = await promiseToFuture(connectTonWallet());
      final wallet = RemoteMobileNode.fromJson(json.decode(jsonWallet));
      setState(() {
        final walletAddressHex = wallet.account?.address ?? "";
        final parts = walletAddressHex.split(":");
        if (parts.length > 1) {
          walletAddress = TonAddress.fromBytes(
            int.tryParse(parts[0]) ?? 0,
            hex.decode(parts[1]),
            bounceable: false,
            testNet: true,
          ).toFriendlyAddress();
        } else {
          walletAddress = walletAddressHex;
        }
        walletImage = wallet.imageUrl ?? "";
      });
      saveToLocalStorage("CONNECTED_WALLET", jsonWallet);
    } catch (e) {
      print(e);
    }
  }

  void _onDisconnect() async {
    try {
      await disconnectTonWallet();
      setState(() {
        walletAddress = "";
      });
      saveToLocalStorage("CONNECTED_WALLET", "");
    } catch (e) {
      print(e);
    }
  }

  void saveToLocalStorage(String key, String value) {
    window.localStorage[key] = value;
  }

  String? getFromLocalStorage(String key) {
    return window.localStorage[key];
  }
}

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>Simple EA Builder</title>
    <style>
        body { font-family: sans-serif; padding: 20px; max-width: 600px; }
        .section { border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .row { margin-bottom: 10px; display: flex; align-items: center; gap: 10px; }
        input[type="number"] { width: 70px; padding: 4px; }
        button { padding: 10px 20px; font-size: 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>

    <h2>簡易EAビルダー</h2>

    <!-- ① 変数定義（インジケーター） -->
    <div class="section">
        <h3>1. インジケーター・変数設定</h3>
        <div class="row">
            <input type="checkbox" id="useSma1" checked>
            <label for="useSma1">短期MA (SMA1) 期間:</label>
            <input type="number" id="sma1Period" value="20">
        </div>
        <div class="row">
            <input type="checkbox" id="useSma2" checked>
            <label for="useSma2">長期MA (SMA2) 期間:</label>
            <input type="number" id="sma2Period" value="50">
        </div>
    </div>

    <!-- ② 基本パラメータ -->
    <div class="section">
        <h3>2. 注文・決済パラメータ</h3>
        <div class="row">
            <label>ロット数:</label> <input type="number" id="lotSize" value="0.1" step="0.01">
            <label>利確(pips):</label> <input type="number" id="tpPips" value="50">
            <label>損切(pips):</label> <input type="number" id="slPips" value="30">
        </div>
    </div>

    <!-- ③ 生成ボタン -->
    <button onclick="buildEA()">EAファイル(.mq4)を出力</button>

    <script>
    function buildEA() {
        // 入力値の取得
        const sma1 = document.getElementById('sma1Period').value;
        const sma2 = document.getElementById('sma2Period').value;
        const lot  = document.getElementById('lotSize').value;
        const tp   = document.getElementById('tpPips').value;
        const sl   = document.getElementById('slPips').value;

        // MQL4コードテンプレート（実際のレイアウトと変数宣言を紐付け）
        const mql4 = `
//+------------------------------------------------------------------+
//| Auto Generated EA                                                |
//+------------------------------------------------------------------+
#property strict

// --- 変数定義（画面上の入力欄と一致） ---
input int    SMA1_Period = ${sma1}; // 短期MA期間
input int    SMA2_Period = ${sma2}; // 長期MA期間
input double LotSize     = ${lot};  // ロット数
input double TakeProfit  = ${tp};   // 利確(pips)
input double StopLoss    = ${sl};   // 損切(pips)

void OnTick() {
   // 注文中のポジションがあれば処理しない（1ポジション限定）
   if(OrdersTotal() > 0) return;

   // 各インジケーター値の計算（1本前の確定足で判定）
   double sma1_prev = iMA(Symbol(), 0, SMA1_Period, 0, MODE_SMA, PRICE_CLOSE, 1);
   double sma2_prev = iMA(Symbol(), 0, SMA2_Period, 0, MODE_SMA, PRICE_CLOSE, 1);
   double sma1_curr = iMA(Symbol(), 0, SMA1_Period, 0, MODE_SMA, PRICE_CLOSE, 0);
   double sma2_curr = iMA(Symbol(), 0, SMA2_Period, 0, MODE_SMA, PRICE_CLOSE, 0);

   // --- エントリー条件 (ゴールデンクロス) ---
   if(sma1_prev <= sma2_prev && sma1_curr > sma2_curr) {
      double ask = MarketInfo(Symbol(), MODE_ASK);
      double point = MarketInfo(Symbol(), MODE_POINT);
      int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
      int pipsFactor = (digits == 3 || digits == 5) ? 10 : 1;

      double slPrice = ask - (StopLoss * point * pipsFactor);
      double tpPrice = ask + (TakeProfit * point * pipsFactor);

      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, ask, 3, slPrice, tpPrice, "Custom EA", 123456, 0, green);
   }
}
`;

        // .mq4 ファイルとして保存・自動ダウンロード
        const blob = new Blob([mql4], { type: 'text/plain' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'MyCustomStrategy.mq4';
        a.click();
    }
    </script>
</body>
</html>

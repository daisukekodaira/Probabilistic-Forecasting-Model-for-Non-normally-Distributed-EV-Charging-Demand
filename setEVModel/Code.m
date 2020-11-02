%% 曜日の表示
% 年、月、日をテーブルから抽出
Year = LongTermEVDatadebug.Year;
Month = LongTermEVDatadebug.Month;
Day = LongTermEVDatadebug.Day;

% 時点を表す配列を作成
t = datetime(Year, Month, Day);

% 曜日を数値で表示
DayNumber = weekday(t);

%% 休日の表示
% 所望の範囲の祝日の検索
Holidays = UKBankHolidays.Date(283:314);

% 与えられた日付を文字列に変換
strt = datestr(t);

% forループでHolidaysと完全一致するか比較
alltrueHolidays = zeros(5846, 1);              %空の配列
for k = 1:32                                   %所望の範囲の休日でループ
    TF = strt == datestr(Holidays(k));         % Holidaysと比較
    allTF = all(TF, 2);                        % 文字列の全ての行が一致するか
    alltrueHolidays = alltrueHolidays + allTF; % trueを抽出
end

% 土日を追加
DayNumber1 = DayNumber == 1;                                 % 日曜
DayNumber7 = DayNumber == 7;                                 % 土曜
alltrueHolidays = alltrueHolidays + DayNumber1 + DayNumber7; % 祝日に追加

%% データの書き込み
LongTermEVDatadebug.DayInWeek = DayNumber;
LongTermEVDatadebug.HolidayOrNot = alltrueHolidays;
writetable(LongTermEVDatadebug, 'LongTermEVData_debugNew.csv');
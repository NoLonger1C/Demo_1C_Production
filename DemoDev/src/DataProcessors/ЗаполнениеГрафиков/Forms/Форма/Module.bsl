
&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	Об = РеквизитФормыВЗначение("Объект");
	Об.Заполнить(Период.ДатаНачала, Период.ДатаОкончания,ВыходныеДни,График);	
КонецПроцедуры

clc; % Komut penceresini temizler
clear all; % Çalışma alanındaki tüm değişkenleri temizler

% Dataset ve test resimlerinin yollarını tanımlayın
datasetFolder = fullfile(pwd, 'dataset');
testImagePath = fullfile(pwd, 'test', 'test1.png');

% Dataset klasörlerindeki her harf veya sayıya ait resimleri alınır
% Klasörlerin her biri bir karakteri temsil eder. örneğin, bir harf veya rakamı temsil eder.
folders = dir(datasetFolder);% Dataset içindeki tüm klasörleri listeler.
folders = folders([folders.isdir]); % Yalnızca klasörleri filtreler.

allImages = {};  % OCR işlemi yapılacak resimler için bir liste oluşturur.
allLabels = {}; % % Resimlere ait etiketler oluşturur. Örneğin, 'A', '5' için bir liste oluşturur.

% Veri setindeki klasörlerden resimleri ve etiketleri alır.
for i = 1:length(folders)
    if ~ismember(folders(i).name, {'.', '..'}) % Geçersiz klasörleri atlar.
        images = dir(fullfile(folders(i).folder, folders(i).name, '*.png')); % Veri seti klasöründeki tüm PNG dosyalarını alır.
        for j = 1:length(images)
            imgPath = fullfile(images(j).folder, images(j).name); % Resim dosyasının tam yolunu alır.
            img = imread(imgPath); % Resmi okur
            allImages{end+1} = img;
            allLabels{end+1} = folders(i).name; % Klasör adı etiketi temsil eder. Örneğin "K" klasörü içinde "K" harfine ait veriler bulunmaktadır.
        end
    end
end

% Eğitim verisi üzerinde OCR uygulama ve doğruluk hesaplama
ocrResults = cell(size(allImages)); % OCR sonuçlarını saklamak için hücre dizisi oluştur
for k = 1:length(allImages)
    ocrResults{k} = ocr(allImages{k}); % Her resim için OCR işlemini uygula
end

% OCR doğruluk hesaplama
correct = 0; % Doğru tahmin sayacı
total = length(allImages); % Toplam resim sayısı
for k = 1:length(allImages)
    ocrText = ocrResults{k}.Text;% OCR sonucunu metin olarak alır.
    if contains(ocrText, allLabels{k})% Beklenen etiket ile karşılaştırır.
        correct = correct + 1;
    end
end

%Test Resmi Üzerinde OCR
% Test resmi üzerinde optik karakter tanıma işlemi yapılır ve sonuç görselleştirilir.
testImage = imread(testImagePath); % Test resmini okur.
ocrResult = ocr(testImage); % OCR işlemini uygular.
ocrText = ocrResult.Text; % OCR sonucunu metin olarak alır.
bbox = ocrResult.CharacterBoundingBoxes; % Tanınan karakterleri kutu içine alır.

% GUI(Kullanıcı arayüzü) oluşturulur.
uiFig = uifigure('Name', 'Optik Karakter Tanıma Sistemi', 'Position', [100, 100, 1200, 600]); % Ana kullanıcı arayüzü penceresi başlığı

% Test Fotoğraflarının orijinal hali sol üstte gösterilir.
axOriginal = uiaxes(uiFig, 'Position', [20, 300, 550, 280]); % Orijial resim için kutu oluşturur.
imshow(testImage, 'Parent', axOriginal);% Orijinal fotoğrafı gösterir.
title(axOriginal, 'Orijinal Fotoğraf');% Başlık

% OCR yapılmış hali sol altta gösterilir.
axOCR = uiaxes(uiFig, 'Position', [20, 20, 550, 280]);% ORC işlemi sonrası sonuç resmi için kutu oluşturur.
imshow(testImage, 'Parent', axOCR); % Orijinal resmi göster
title(axOCR, 'Optik Karakter Tanıma ile Fotoğraf'); % Başlık
hold(axOCR, 'on');% Çizim yapar.
for i = 1:size(bbox, 1)% Her bir karakterin kutusunu çizer.
    rectangle(axOCR, 'Position', bbox(i, :), 'EdgeColor', 'r', 'LineWidth', 1.5);% Kutuları çizer.
end
hold(axOCR, 'off');% Çizimi kapatır.

% OCR metni gösterme
uilabel(uiFig, 'Text', 'ORC ile Tanınan Metin:', 'Position', [600, 550, 200, 30], 'FontSize', 14, 'FontWeight', 'bold');% Başlık
uitextarea(uiFig, 'Value', {ocrText}, 'Position', [600, 50, 550, 500], 'Editable', 'off', 'FontSize', 12, 'HorizontalAlignment', 'left');% Metin alanı.
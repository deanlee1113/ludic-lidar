-- 판매 목록 로드의 연식·주 용도 (2026-11-01 조사)
-- 원칙: 제조사 페이지(웨이백 아카이브 포함)·공식몰·판매처 상세에 적힌 것만 옮긴다. 출처에 없으면 비워 둔다(null).
-- 연식은 출시 연도. 용도는 출처에 적힌 대상어·채비·수심·루어 무게를 짧게 줄였다.

-- 시마노 세피아 (fishing.shimano.co.jp/product/rod/5370·5599·5834·6120·6285·5347 아카이브, fish.shimano.com 현행 페이지)
update stock_items set model_year='2022년', fishing='무늬오징어 에깅 · 솔리드팁 · 에기 2~4호' where id=201;
update stock_items set model_year='2022년', fishing='무늬오징어 에깅 · 에기 2~4호' where id=202;
update stock_items set model_year='2018년', fishing='팁런 에깅 · 섬세형 · 에기 60g까지' where id=203;
update stock_items set model_year='2018년', fishing='팁런 에깅 · 파워형 · 에기 80g까지' where id=204;
update stock_items set model_year='2019년', fishing='이카메탈(베이트) · 수심 10~60m' where id=205;
update stock_items set model_year='2019년', fishing='팁런 에깅 · 섬세형 · 수심 40m까지' where id=206;
update stock_items set model_year='2019년', fishing='팁런 에깅 · 파워형 · 수심 50m까지' where id=207;
update stock_items set model_year='2020년', fishing='무늬오징어 에깅 · 경쾌한 조작 · 에기 1.8~3.8호' where id=208;
update stock_items set model_year='2020년', fishing='무늬오징어 에깅 · 올라운드 · 에기 1.8~3.8호' where id=209;
update stock_items set model_year='2020년', fishing='무늬오징어 에깅 · 대형·빠른 조류 · 에기 2~4호' where id=210;
update stock_items set model_year='2022년', fishing='팁런 에깅 · 올라운드 · 수심 20~50m' where id=211;
update stock_items set model_year='2018년', fishing='팁런 에깅 · 파워형 · 에기 80g까지' where id=212;
update stock_items set model_year='2022년', fishing='오모리그(스피닝) · 봉돌 20~40호' where id=213;
update stock_items set model_year='2022년', fishing='이카메탈(베이트) · 수심 10~80m' where id=214;
-- 215: SS 메탈 슷테 시리즈는 2019년, 이 번수(S70MH-S/R)는 2022년 추가
update stock_items set model_year='2022년', fishing='오모리그(스피닝) · 봉돌 20~40호' where id=215;
update stock_items set model_year='2021년', fishing='이카메탈(베이트) · 수심 0~60m' where id=216;
update stock_items set model_year='2018년', fishing='이카메탈(스피닝) · 수심 10~60m' where id=217;

-- 시마노 염월 XR (fishing.shimano.co.jp/product/rod/6290 2021-04 아카이브: 2021年3月発売予定, 鯛ラバ)
update stock_items set model_year='2021년', fishing='참돔 타이라바 · 풀솔리드 · 헤드 30~100g' where id in (218,219);
update stock_items set model_year='2021년', fishing='참돔 타이라바 · 풀솔리드 · 느린 조류·저활성' where id in (220,221);
update stock_items set model_year='2021년', fishing='참돔 타이라바 · 풀솔리드 · 헤드 40~150g' where id=222;
update stock_items set model_year='2021년', fishing='참돔 타이라바 · 솔리드팁 · 헤드 30~100g' where id=223;

-- 기간이즘(KIGANISM) — 출시 연도는 공식·판매처 어디에도 없어 비워 둔다
-- 3GO-B·TH-B·3GO-SR: kiganism.com 공식 스펙표 / THC-B: 판매처(bbongfishing) 브랜드 상세 이미지
update stock_items set fishing='배스 · 루어 최대 3/4oz' where id=224;
update stock_items set fishing='배스 · 루어 최대 1oz' where id=225;
update stock_items set fishing='배스 · 루어 최대 1½oz' where id=226;
update stock_items set fishing='배스 · 다운샷·네꼬·지그헤드' where id=227;
update stock_items set fishing='배스 · 중량 바닥채비 · 싱커 1/4~1oz' where id=228;
update stock_items set fishing='쏘가리 · 루어 2~10g' where id=229;
update stock_items set fishing='쏘가리 · 루어 3~16g' where id in (230,231);
update stock_items set fishing='배스 · 루어 1/4~3/4oz' where id=232;

-- JS컴퍼니 — jscompanymall.net 공식몰 모델 설명. NIXX POP 2 출시 연도는 확인 안 됨
update stock_items set fishing='배스 · 소형 하드베이트·지그' where id=233;
update stock_items set fishing='배스 · 저크·크랭크·스피너베이트' where id=234;
-- BIXOD B1 2021: 연도는 품명·판매처 상품명 "빅소드 B1 (2021)" 기준
update stock_items set model_year='2021년', fishing='배스 · 프리리그·와이어베이트' where id=235;
update stock_items set model_year='2021년', fishing='배스 · 1oz 지그·버징·스윔베이트' where id=236;

-- 블랙홀(엔에스) — nsrod.co.kr 신제품 공지(웨이백): 다크호스Ⅱ 배스 2023-02-23, 실크로드2 에디션 2023-04-04
-- 다크호스Ⅱ: 공식 제품 페이지(idx=249) 모델 설명 / 실크로드2: 공식 상세 이미지 모델 설명·스펙표(idx=211)
update stock_items set model_year='2023년', fishing='배스 · 다운샷·와키·네드·네꼬리그' where id=237;
update stock_items set model_year='2023년', fishing='배스 · 베이트 피네스(저크·탑워터)' where id=238;
update stock_items set model_year='2023년', fishing='배스 · 텍사스·프리리그·러버지그' where id=239;
update stock_items set model_year='2023년', fishing='배스 · 텍사스·프리리그·와이어베이트' where id=240;
update stock_items set model_year='2023년', fishing='배스 · 빅베이트 2~5oz' where id=241;
update stock_items set model_year='2023년', fishing='배스 · 지그헤드·다운샷·네꼬·노싱커' where id=242;
update stock_items set model_year='2023년', fishing='배스 · 라이트 채비 장타·미노우 저킹' where id=243;
update stock_items set model_year='2023년', fishing='배스 · 워킹 올라운드(하드베이트·웜)' where id=244;
update stock_items set model_year='2023년', fishing='배스 · 텍사스 러버지그·프리리그' where id in (245,250);
update stock_items set model_year='2023년', fishing='배스 · 커버·알라바마·빅베이트' where id=246;
-- 247~249: 공식 상세 이미지가 이 셋을 스펙이 다른 모델 설명과 묶어 두어서, 스펙표의 루어 무게만 옮긴다
update stock_items set model_year='2023년', fishing='배스 · 루어 1/4~1oz' where id=247;
update stock_items set model_year='2023년', fishing='배스 · 루어 3/8~4oz · PE 2~5호' where id=248;
update stock_items set model_year='2023년', fishing='배스 · 루어 3/8~5oz · PE 3~6호' where id=249;

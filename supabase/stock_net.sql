-- 2026-11-01 밤: 방송에서 정한 릴 가격과 인터넷 최저가(한국 정품 새 제품). stock.sql(net_*, unit_price 칸)을 먼저 적용할 것
-- 처음 가격(was_price) = 처음 올린 가격. 판매 목록에 줄 그어 보인다
update public.stock_items set was_price = 400000, price = 360000 where id = 101; -- 트윈파워 C2000S (20)
update public.stock_items set was_price = 480000, price = 440000 where id = 116; -- 비비엑스 HF C3000DXG (22)
update public.stock_items set was_price = 360000, price = 330000 where id = 119; -- 20 루비아스 LT 3000C

-- 인터넷 최저가: 판매처 페이지에서 직접 확인한 값. 해외배송·직수입·병행·중고·정품 표기 없는 매물은 뺐다.
-- 연식이 다른 후속 모델 가격과는 비교하지 않는다(사용자: "년식이 중요해"). 같은 연식의 정품 매물이 없으면 비워 둔다:
--   101 트윈파워 C2000S(20) 정품 품절 / 102 반포드 C2000S(20) 정품 C2000S 재고 못 찾음(연식 미표기 윤성정품 240,000 G마켓은 판매자 확인 전)
--   108 염월 프리미엄 150HG(18) 정품 표기 매물 없음 / 109·110 오시아 콘퀘스트 200HG(14)·200PG(15) 정품 품절
-- G마켓·옥션·11번가는 다나와를 거쳐 들어가면 10% 안팎 싸게 나와서, 그 값을 확인한 곳은 더 싼 쪽을 썼다(판매처에 바로 들어가면 더 비싸게 보임).
-- 판매 목록에는 우리 가격보다 높을 때만 보인다.
update public.stock_items s set net_price = v.p, net_label = v.l, net_url = v.u
from (values
  (103, 294300, null, 'https://www.11st.co.kr/products/9236910806'),              -- 11번가 홍태공 20 반포드 윤성정품
  (104, 186010, null, 'https://www.11st.co.kr/products/9478753464'),              -- 11번가 나눔피싱 다나와 경유가(바로 들어가면 209,000 + 배송비 3,300)
  (105, 256000, null, 'https://prod.danawa.com/info/?pcode=9831414'),             -- 다나와에 뜬 네이버 고피싱 윤성보증(판매처 페이지는 못 염). 확인된 최저는 308,000
  (106, 340200, null, 'https://item.gmarket.co.kr/Item?goodscode=4175708433'),    -- G마켓 피싱미니샵 다나와 경유가(바로 들어가면 378,000, 쿠폰 375,000)
  (107, 251100, null, 'https://item.gmarket.co.kr/Item?goodscode=3678234336'),    -- G마켓 fishing유강 윤성보증 다나와 경유가(바로 들어가면 279,000)
  (111, 272630, null, 'https://item.gmarket.co.kr/Item?goodscode=2885141289'),    -- G마켓 원낚시 윤성정품 다나와 경유가(바로 들어가면 309,800)
  (112, 249000, null, 'https://www.coupang.com/vp/products/6965323709?itemId=16971300322&vendorItemId=92141552425'), -- 쿠팡 윤성정품 101PG(검색 결과에서 확인)
  (113,  93000, null, 'https://wonfishing.com/product/detail.html?product_no=4652'), -- 원낚시 자사몰 윤성정품
  (114,  93500, null, 'https://wonfishing.com/product/detail.html?product_no=4653'), -- 원낚시 자사몰 윤성정품
  (115, 145500, null, 'https://wonfishing.com/product/detail.html?product_no=4481'), -- 원낚시 자사몰 윤성정품
  (116, 467000, null, 'https://wonfishing.com/product/detail.html?product_no=4433'), -- 원낚시 자사몰 윤성정품(좌우겸용, S 타입 아님)
  (117,  44350, null, 'https://prod.danawa.com/info/?pcode=15348359'),            -- 11번가 마린피싱 윤성정품 다나와 경유가 + 배송비 3,500(바로 들어가면 50,400)
  (119, 350100, null, 'https://item.gmarket.co.kr/Item?goodscode=3401264572')     -- G마켓 원낚시 한국정품 다나와 경유가(바로 들어가면 389,000)
) as v(id, p, l, u)
where s.id = v.id;

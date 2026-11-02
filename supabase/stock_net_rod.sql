-- 2026-11-03: 로드 인터넷 최저가(국내 판매 새 제품). stock.sql(net_* 칸)을 먼저 적용할 것. 방송 로드 가격표(live/index.html ROD_NET)와 같은 값
-- 판매처 상품 페이지에서 규격 옵션·재고·배송비까지 직접 확인한 값. 해외배송·직구·병행·중고·정품 표기 없는 매물은 뺐다.
-- 연식(세대)이 다른 후속 모델과는 비교하지 않는다. 같은 연식 국내 매물이 없으면 비워 둔다:
--   201 세피아 BB S86M-S(22) [해외]·중고만 / 217 세피아 BB 메탈 슷테 S66ML-S(18) 18년형 국내 매물은 B66 계열뿐
--   301~303 루딕 라이다는 우리 브랜드라 비교하지 않는다
-- 누구나 받는 쿠폰가(G마켓 쿠폰받기, SSG 쓱데이 8% 쿠폰 11/8까지)와 다나와 경유가(G마켓·옥션·11번가 약 10%)가 더 싸면 그 값을 썼다.
-- 판매처에 바로 들어가면 더 비싸게 보일 수 있다. 네이버 스마트스토어는 접속이 막혀 확인하지 못해 뺐다.
-- 판매 목록에는 우리 가격보다 높을 때만 보인다.
update public.stock_items s set net_price = v.p, net_label = null, net_url = v.u
from (values
  -- 시마노 세피아 BB·SS
  (202, 175780, 'https://www.11st.co.kr/products/6967042083'),                 -- 11번가 원낚시 22 세피아 BB S86M 윤성정품(배송비 4,000 별도)
  (203, 178760, 'https://www.11st.co.kr/products/7039799323'),                 -- 11번가 신세계몰 (18) 팁에깅 S66ML-S 옵션, 윤성정품
  (204, 169860, 'https://www.11st.co.kr/products/5748959463'),                 -- 11번가 신세계몰 팁에깅 S66M-S (18) 윤성정품
  (212, 199400, 'https://item.gmarket.co.kr/Item?goodscode=3183810543'),       -- G마켓 오리피싱 팁에깅 S70M-S (18) 쿠폰가(쿠폰 없이 202,400)
  (205, 200000, 'https://item.gmarket.co.kr/Item?goodscode=3848882850'),       -- G마켓 피싱마트21 19 세피아SS 메탈슷테 B66M-S 옵션, 윤성정품
  (206, 281070, 'https://item.gmarket.co.kr/Item?goodscode=2683582572'),       -- G마켓 신세계몰 S66ML-S (19) 쿠폰가(쿠폰 없이 312,290, 11번가 296,680)
  (207, 278000, 'https://item.gmarket.co.kr/Item?goodscode=1845883504'),       -- G마켓 굿데이낚시 269,000 + S66M-S (19) 옵션 9,000, 윤성정품
  (215, 306160, 'https://www.11st.co.kr/products/8103142356'),                 -- 11번가 또또낚시 세피아 SS 메탈 슷테 S70MH-S/R (22) 윤성정품
  -- 시마노 세피아 엑스튠·XR, 염월 XR
  (208, 498000, 'https://www.coupang.com/vp/products/7823782712?itemId=21258424559&vendorItemId=88318817746'), -- 쿠팡 홍태공 20 엑스튠 S82ML 윤성정품
  (209, 500000, 'https://www.coupang.com/vp/products/6924326262?itemId=16733357251&vendorItemId=93502479298'), -- 쿠팡 다잡아낚시 S86ML(20)
  (210, 423000, 'https://item.gmarket.co.kr/Item?goodscode=4614754205'),       -- G마켓 굿데이낚시 S86M (20) 다나와 경유가(바로 470,000), 배송비 8,000
  (211, 423200, 'https://www.11st.co.kr/products/9715890541'),                 -- 11번가 원낚시 22 세피아 XR 팁에깅 S68ML-S/R 다나와 경유가(바로 475,500)
  (213, 344500, 'https://www.coupang.com/vp/products/6583321007?itemId=19357049597&vendorItemId=92141511363'), -- 쿠팡 굿데이낚시 XR 메탈 슷테 S70MH-S/R(22) 윤성정품
  (214, 339200, 'https://www.coupang.com/vp/products/7612942798?itemId=20166647221&vendorItemId=92141511317'), -- 쿠팡 굿데이낚시 XR 메탈 슷테 B66M-S/F (22) 윤성정품
  (216, 467000, 'https://www.coupang.com/vp/products/7881357381?itemId=24451804557&vendorItemId=93502125097'), -- 쿠팡 다잡아낚시 엑스튠 메탈 슷테 B66ML-S/F (21)
  (218, 280000, 'https://www.coupang.com/vp/products/7663031167?itemId=20420488988&vendorItemId=95384952974'), -- 쿠팡 노마진낚시 21 염월 XR FS-B55ML(RIGHT) 윤성정품
  (219, 280000, 'https://www.coupang.com/vp/products/6165761694?itemId=12029685074&vendorItemId=95384952978'), -- 쿠팡 노마진낚시 21 염월 XR FS-B55ML(LEFT) 윤성정품
  (220, 324000, null),                                                         -- G마켓 원낚시 정품 다나와 경유가(바로 360,000). 정품 표기 없는 쿠팡 만어낚시 310,000은 뺌
  (221, 292950, null),                                                         -- G마켓·옥션 원낚시 정품 다나와 경유가. 정품 표기 없는 쿠팡 280,000은 뺌
  (222, 366300, 'https://itempage3.auction.co.kr/DetailView.aspx?itemno=D642712285'), -- 옥션 원낚시 21 염월 XR FS-B66M RIGHT 윤성정품 다나와 경유가(바로 407,000)
  (223, 250900, 'https://www.11st.co.kr/products/9454490308'),                 -- 11번가 또또낚시 N-B610ML-S RIGHT 윤성정품 다나와 경유가(바로 281,900)
  -- 블랙홀(NS) 다크호스2 배스·실크로드2 에디션(2023)
  (237, 107640, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557578077'), -- SSG 쓱데이 쿠폰가(쿠폰 없이 117,000)
  (238, 111780, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557578057'), -- SSG 쿠폰가(121,500)
  (239, 111780, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557578015'), -- SSG 쿠폰가(121,500)
  (240, 111780, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557578001'), -- SSG 쿠폰가(121,500)
  (241, 115920, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577966'), -- SSG 쿠폰가(126,000)
  (242, 182160, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577925'), -- SSG 쿠폰가(198,000)
  (243, 190440, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577907'), -- SSG 쿠폰가(207,000)
  (244, 194580, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577886'), -- SSG 쿠폰가(211,500)
  (245, 211680, 'https://www.ssg.com/item/itemView.ssg?itemId=1000659303974'), -- SSG (주)규 C-752MH 옵션 2% 즉시할인(216,000)
  (246, 202860, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577846'), -- SSG 쿠폰가(220,500)
  (247, 211500, 'https://www.coupang.com/vp/products/9099468318?itemId=26748169054&vendorItemId=93719287867'), -- 쿠팡 이누잇코리아 시트분리(ONE&HALF) C-722M
  (248, 207000, 'https://www.ssg.com/item/itemView.ssg?itemId=1000557577811'), -- SSG 쿠폰가(225,000). 141g·2.21m = 시트분리 C-732XH
  (249, 229500, 'https://www.coupang.com/vp/products/7246610054?itemId=18423933439&vendorItemId=85565770609'), -- 쿠팡 국선조구 C-762XXH(시트분리)
  (250, 216000, 'https://www.coupang.com/vp/products/9099468318?itemId=26748169060&vendorItemId=93719287871'), -- 쿠팡 이누잇코리아 시트분리(ONE&HALF) C-762MH
  -- 기간이즘(3GO-B는 접미사 없는 티타늄 MICRO판 기준, -SG판은 약 150,000)
  (224, 150000, 'https://www.coupang.com/vp/products/8655058299?itemId=25124920233'), -- 쿠팡 바모스피싱 '티타늄 마이크로스페셜/C682M' 옵션
  (225, 158500, 'https://www.coupang.com/vp/products/9347738711?itemId=27728022891'), -- 쿠팡 에너지스토리 (티타늄마이크로) C672MH
  (226, 158500, 'https://www.coupang.com/vp/products/9347738711?itemId=27728022892'), -- 쿠팡 에너지스토리 (티타늄마이크로) C692H
  (227, 290000, 'https://www.coupang.com/vp/products/8242731821?itemId=23720110215'), -- 쿠팡 광명낚시왕 THC-B(티탄하츠 CZH) S682L
  (228, 300000, 'https://www.coupang.com/vp/products/8242732414?itemId=23720111963'), -- 쿠팡 광명낚시왕 THC-B C682MH
  (229, 160000, 'https://www.coupang.com/vp/products/4899553210?itemId=6390945668'),  -- 쿠팡 대박낚시 3GO-SR/S602UL
  (230, 163350, 'https://www.coupang.com/vp/products/9347737494?itemId=27728017490'), -- 쿠팡 에너지스토리 3GO-SR S632L
  (231, 170000, 'https://www.coupang.com/vp/products/4899553210?itemId=6390945670'),  -- 쿠팡 대박낚시 3GO-SR/S662L
  (232, 265000, 'https://www.coupang.com/vp/products/9525130162?itemId=28398999907'), -- 쿠팡 아프리카 Fishing TH-B/C682M(티탄하츠 배스게임)
  -- JS컴퍼니
  (233, 99000,  'https://www.coupang.com/vp/products/6378567433?itemId=13542103770&vendorItemId=91020867538'), -- 쿠팡 하나피싱 닉스팝2 S662ML
  (234, 88000,  'https://www.coupang.com/vp/products/8705756725?itemId=25282055363&vendorItemId=92277617543'), -- 쿠팡 만어낚시 닉스팝2 BC652MR
  (235, 186500, 'https://www.coupang.com/vp/products/7198322984?itemId=18189485056&vendorItemId=4567114944'),  -- 쿠팡 와우낚시 빅쏘드 B1 2021 BC692MH
  (236, 189000, 'https://www.coupang.com/vp/products/7198322975?itemId=18189484976&vendorItemId=92149027797')  -- 쿠팡 에프마켓 김포 빅쏘드 B1 2021 BC712H
) as v(id, p, u)
where s.id = v.id and s.kind = 'rod';

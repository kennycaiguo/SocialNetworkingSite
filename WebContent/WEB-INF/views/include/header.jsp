<%@ page import="com.team5.dto.Member"%>
<%@ page language="java" contentType="text/html;charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link href="/team5/styles/css/bootstrap.min.css" rel="stylesheet" />
<link href="/team5/styles/default.css" rel="stylesheet" />

<script src="http://code.jquery.com/jquery.js"></script>
<script src="/team5/styles/js/bootstrap.min.js"></script>


<script type="text/javascript">
	var proxy;//XMLHttpRequest 객체 참조변수
	//count=0;
	//여기부터 자동 완성 기능 구현
	//문서에서 자동완성박스 이외의 영역을 클릭했을 때 호출될 메서드 정의

	document.onclick = function(event) {
		var d = document.getElementById('divAutoCom');
		if (d) {
			document.body.removeChild(d);//화면에서 제거
		}
	};

	function doAutoComplete() {
		//사용자가 입력한 아이디 읽기
		var id = document.getElementById("search");

		if (id.value.length == 0) {
            var d = document.getElementById('divAutoCom');
            if (d) {
				document.body.removeChild(d);//화면에서 제거
			}
			return;
		}

		//읽은 아이디가 1문자 이상 :XMLHttpRequest 객체를 사용해서 비동기 요청 전송
		proxy = new XMLHttpRequest();
		proxy.open("GET", "/team5/getsuggestions.action?id=" + id.value, true);
		proxy.onreadystatechange = showSuggestions;
		proxy.send(null);
		//수신 결과 alert로 출력		
	}

	function showSuggestions() {
		if (proxy.readyState == 4) {
			if (proxy.status != 200) {
				//alert('error ' + proxy.status);
				return;
			}
			var result = proxy.responseText;
				//alert(result);
			showResult(result);
		}
	}


	var divList = null;
	function showResult(data) {
		//이미 표시되고 있는 자동완성 박스가 있으면 제거
		var d = document.getElementById('divAutoCom');
		if (d) {
			document.body.removeChild(d);//화면에서 제거
		}

		if (data.length == 0){
            return;
		}

		//1. outter box------------------------------
		divList = document.createElement("div");

		divList.id = "divAutoCom";
		divList.style.border = "1px	black solid";
		divList.style.backgroundColor = "white";
		divList.style.width = "230px";
		divList.style.position = "absolute";
		divList.style.left = "50px";

		document.body.appendChild(divList);

		//2. inner box --------------------------------
		var item; var nameArray = data.split(";");
        for (var i = 0; i < nameArray.length; i++) {
			item = document.createElement("div");

			item.style.paddingLeft = "5px";
			item.style.paddingTop = "5px";
			item.style.paddingBottom = "2px";
			item.style.width = "97%";
			item.innerHTML = nameArray[i];//데이터 지정

			divList.appendChild(item);

			//2.1 event
			item.onmousedown = function(oEvent) {
				oEvent = oEvent || window.event;
				oSrcElement = oEvent.target || oEvent.srcElement;
				document.getElementById("search").value = oSrcElement.innerHTML;
				divList.style.display = "none";
			};
			item.onmouseover = function(oEvent) {
				oEvent = oEvent || window.event;
				oSrcElement = oEvent.target || oEvent.srcElement;
				oSrcElement.style.backgroundColor = "#efefef";
			};
			item.onmouseout = function(oEvent) {
				oEvent = oEvent || window.event;
				oSrcElement = oEvent.target || oEvent.srcElement;
				oSrcElement.style.backgroundColor = "";
			};
		}

		//3. outterbox placement
		divList.style.left = getLeft() + "px";
		divList.style.top = getTop() + "px";
	}




    function getTop() {
		var t = document.getElementById("search");
		var topPos = 2 + t.offsetHeight;
		while (t.tagName.toLowerCase() != "body" && t.tagName.toLowerCase() != "html") {
			topPos += t.offsetTop;//offsetTop : 상위 요소와의 거리
			t = t.offsetParent; //상위 요소를 현재 요소에 대입
		}
		return topPos;
	}

	function getLeft() {
		var t = document.getElementById("search");
		var leftPos = 0;
		while (t.tagName.toLowerCase() != "body" && t.tagName.toLowerCase() != "html") {
			leftPos += t.offsetLeft;//t와 t좌측 요소 사이의 거리
			t = t.offsetParent;//t의 좌측 요소
		}
		return leftPos;
	}

    //==============     Update Profile Photo          =============//


    var proxy = null;
    function changprofilepic() {
        // proxy readyState code: 1:pre-request, 2:post-request, 3:pre-respond, 4:post-respond
        // proxy status code: 200 success
        if (proxy.readyState == 4) {
            if (proxy.status == 200) {
                //읽은 데이터를 배분
                var result = proxy.responseText;
                alert(result);
                //eval : String to Code: "var a = 10" -> var a = 10;
                document.getElementById('profilepic').src = '/team5/upload/' + result;
                //JQuery $(selector)과 비슷한 기능: '(inline tage, class)#profilepic'인 모든 요소를 List로 Return
                var list = document.querySelectorAll(".profilepic");
                for (var i in list) {
                    list[i].src = '/team5/upload/' + result;
                }
            } else {
                alert('오류 :' + proxy.status);
            }
        }
    }

    function doUpdatePicture(memberId, fileName) {

        //location.href='/team5/member/updateprofilepic.action?
        //               memberid=${loginuser.memberId}&profilepic=${uploadfile.savedFileName}';

        proxy = new XMLHttpRequest();//Ajax
        proxy.open("GET", "/team5/member/updateprofilepic.action?memberid=" + memberId + "&profilepic=" + fileName, true);
        proxy.onreadystatechange = changprofilepic;
        proxy.send(null);
    }


    function changeImage(from) {
        //소스만 바꿔주면 됨.
        var cover = document.getElementById("cover");
        cover.src = from.src;
    }


    //==============   Toggle Board and Comment         =============//

    var v2 = null;
    var e2 = null;
    var editlink = null;
    var updatelink = null;
    var cancellink = null;
    function toggleBoardStatus(boardNo, edit) {
        if (v2 != null) {
            v2.style.display = edit ? 'block' : 'none';
            e2.style.display = edit ? 'none' : 'block';
        }
        v2 = document.getElementById("boardcontentview" + boardNo);
        e2 = document.getElementById("boardcontentedit" + boardNo);

        editlink = document.getElementById("boardeditlink" + boardNo);
        updatelink = document.getElementById("boardupdatelink" + boardNo);
        cancellink = document.getElementById("boardcancellink" + boardNo);

        v2.style.display = edit ? 'none' : 'block';
        e2.style.display = edit ? 'block' : 'none';

        editlink.style.display = edit ? 'none' : 'inline';
        updatelink.style.display = edit ? 'inline' : 'none';
        cancellink.style.display = edit ? 'inline' : 'none';
    }


    var v = null, e = null;
    function toggleCommentStatus(commentNo, edit) {
        if (v != null) {
            v.style.display = edit ? 'block' : 'none';
            e.style.display = edit ? 'none' : 'block';
        }
        v = document.getElementById("commentview" + commentNo);
        e = document.getElementById("commentedit" + commentNo);

        v.style.display = edit ? 'none' : 'block';
        e.style.display = edit ? 'block' : 'none';
    }


    //==============     DELECT COMMENT and BOARD           =============//


    function deleteComment(commentNo, boardNo) {
        var yes = confirm(commentNo + '번 댓글을 삭제 할까요?');
        if (yes) {
            location.href = 'deletecomment.action?' +
                'commentno=' + commentNo + "&boardno=" + boardNo;
        }
    }

    function doDelete(boardNo, pageNo) {
        yes = confirm(boardNo + '번 글을 삭제할까요?');
        if (yes) {
            location.href = 'delete.action?' +
                'boardno=' + boardNo + '&pageno=' + pageNo;
        }
    }

    //==============     SEARCH           =============//

	function dofriendSearch() {
		var search = document.getElementById("search");
		location.href = '/team5/friend/friendSearch.action?search=' + search.value;
	}

	/* function loginCheck(){
	 var passwd=document.getElementById("passwd");
		 if(passwd.value.length==0){
			alret("비밀번호를 써주세요");
		 }
	 }
	 */


	//===========      Comment   ==================//
	function doCommentConfirm() {

		/* var createDiv=document.createElement("div");
		createDiv.innerHTML="가 댓글을 등록했습니다.";	 
		table.td.appendChild(createDiv); */

		//var table=document.getElementById("table");
		setTimeout("doCommentConfirm()", 2000);

		//XMLHttpRequest 객체를 사용해서 비동기 요청 전송
		proxy = new XMLHttpRequest();
		proxy.open("GET", "/team5/commentConfirm.action", true);
		proxy.onreadystatechange = showComment;
		proxy.send(null);
	}

	function showComment() {
		if (proxy.readyState == 4) {
			if (proxy.status != 200) {
				//alert('error ' + proxy.status);
				return;
			}
			var result = proxy.responseText;
			//alert(result);
			showCommentResult(result);
		}
	}

	function showCommentResult(data) {
		//이미 표시되고 있는 자동완성 박스가 있으면 제거
		var d = document.getElementById('divComment');
		if (d) {
			document.body.removeChild(d);//화면에서 제거
		}

		if (data.length == 0){
            return;
		}

		//외부 박스 만들기
		divList = document.createElement("div");
		divList.id = "divComment";
		divList.style.border = "1px	black solid";
		divList.style.backgroundColor = "white";
		divList.style.width = "230px";
		divList.style.position = "absolute";//다른 마크업 위에 표시		
		document.body.appendChild(divList);

		//내부 박스 만들기
		var item; var nameArray = data.split(";");
        for (var i = 0; i < nameArray.length; i++) {
			item = document.createElement("div");
			item.style.paddingLeft = "5px";
			item.style.paddingTop = item.style.paddingBottom = "2px";
			item.style.width = "97%";
			item.innerHTML = nameArray[i];//데이터 지정
			divList.appendChild(item);
		}

		//외부 박스의 위치 지정
		/* divList.style.left = getLeft() + "px";
		divList.style.top =	getTop() + "px"; */

		divList.style.left = "1200px";
		divList.style.top = "100px";

		//count=count+1;
	}


</script>

		<div id="header">
			<div class="title">
				<h1>
					<a href="#">fakebook</a>
				</h1>
			</div>
				<c:if test="${not empty sessionScope.loginuser }">
					<nav class="navbar navbar-right navbar-fixed-top">
						<div class="containter">
							<div class="btn-group">
								<input type="text" id="search" placeholder="지역/학교/이름 입력" name="search" style="width: 150px; color: #010802"
									   onkeyup="doAutoComplete();" />

								<input type="button"  class="btn btn-primary" style="color: #010802" value="검색"
									   onclick="dofriendSearch();" />

								<input type="button" class="btn btn-primary" id="memberEmail" value="${ loginuser.email }"
									   onclick="location.href='/team5/memberdetail/detail.action?memberid=${ loginuser.memberId }'">

								<input type="button" class="btn btn-primary" id="logout" value="로그아웃"
									   onclick="location.href='/team5/account/logout.action'">

								<input type="button" class="btn btn-primary" id="friendReceiveForm" value="친구요청"
									   onclick="location.href='/team5/friend/friendReceiveForm.action'">

								<input type="button" class="btn btn-primary" id="alarm" value="메세지알림"
									   onclick="location.href='#'">

								<input type="button" class="btn btn-primary" id="home" value="타임라인"
									   onclick="location.href='/team5/board/list.action'">

								<input type="button" class="btn btn-primary" id="friend" value="친구"
									   onclick="location.href='/team5/friend/friendViewForm.action'">
							</div>
				</c:if>
				<!------------------------   로그인 안했을 경우 -------------------------------->
				<c:if test="${empty sessionScope.loginuser}">
					<div class="links">

						<form class="form-inline" align="right" action="/team5/login.action" method="post" >
							<div class="form-group">
								<label for="inputEmail">이메일 </label>
								<input type="email" class="form-control" id="inputEmail" name="email"
									   placeholder="Email" style="width: 250px" >

								<label for="passwd">비밀번호 </label>
								<input type="password" class="form-control" id="passwd" name="passwd"
									   placeholder="Password" style="width: 180px; color: #010802" />

								<input type="submit" class="btn btn-primary" id="login" name="login " value="로그인">
							</div>
						</form>

					</div>
				</c:if>
		</div>
	</nav>
</div>

<body onload="doCommentConfirm();">
	<div id="commentConfirm" float="right"></div>
</body>


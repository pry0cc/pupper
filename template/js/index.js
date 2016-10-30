function generatehome() {
  var articles = "";
  $.ajax({
    dataType: "json",
    url: 'http://127.0.0.1:8000/articles/articles.json',
    data: articles,
    success: console.log("success")
  });
  var parsed = JSON.parse(articles);
  alert(parsed);
  // $("#previews").html("")
}

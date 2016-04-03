function refreshList() {
    var query = $('#query').text();
    url = '/sampler/refresh?keyword=' + query;
    $.ajax({
        type: 'POST',
        url:  url,
        datatype: 'xml',
        success: function(responseText,status) {
            $('#videoCarousel div.item').remove();
            $('#selectorCarousel div.item').remove();
            $('#selectorCarousel > ol.carousel-indicators > li').remove();
            var $videoInner = $('#videoCarousel > div.carousel-inner');
            var $selectorInner = $('#selectorCarousel > div.carousel-inner');
            var $selectorIndicators = $('#selectorCarousel > ol.carousel-indicators');
            var $xml = $(responseText);
            var $movie = $xml.find('movie');
            
            var selector_number = 0;
            var item_number = 0;
            var block_number = 0; // 1段分のサムネイル数。4になったら改段する。
            var $selectorItem = null;
            var $selectorRowDiv;
            var $selectorRow;
            jQuery.each($movie,function(total_number) {
                var $movie = $(this);
                var $videoItem;
                var $video = $('<video src="http://' + $movie.find("movie_url").text() + '" controls ></video>');
                if (total_number == 0) {
                  $videoItem = $('<div>').attr({'class':'item active','name':total_number})
                  $videoInner.append($videoItem);
                } else {
                  $videoItem = $('<div>').attr({'class':'item','name':total_number})
                  $videoInner.append($videoItem);   
                }
                $videoItem.append($video);
                display_value = $videoItem.css("display")
                $videoItem.css("display","block");
                $tagsDiv = $('<div class="tags"></div>');
                $videoItem.append($tagsDiv);
                $pDiv = $('<p></p>');
                $tagsDiv.append($pDiv);
                tags_width = $tagsDiv.width();
                total_tag_width = 0;
                $tags = $movie.find('tag')
                jQuery.each($tags,function() {
                  $tag = $('<a href="/sampler/search?keyword='+$(this).text()+'"><span class="label label-success">'+$(this).text()+'</span></a>')
                  $pDiv.append($tag);
                  total_tag_width += $tag.outerWidth(true);
                  if(total_tag_width > tags_width) {
                    $tag.remove();
                    $tagsDiv.append($pDiv);
                    total_tag_width = 0;
                    $pDiv = $('<p></p>');
                    $tagsDiv.append($pDiv);
                  }
                });
                $descLink = $('<a href="http://www.dmm.co.jp/litevideo/-/detail/=/cid=' + $movie.find("dmm_id").text() + '/quotto-003"><span class="label label-danger">この動画の詳細</span></a>');
                $pDiv.append($descLink);
                if(total_tag_width > tags_width) {
                  $descLink.remove();
                  $tagsDiv.append($pDiv);
                  total_tag_width = 0;
                  $pDiv = $('<p></p>');
                  $tagsDiv.append($pDiv);
                }
                $videoItem.css("display","");
                if(item_number == 0 ) {
                  $selectorRow = $('<div class="selector_row">');
                    if(selector_number == 0) {
                        $selectorItem = $('<div class="selector item active">');
                        $selectorIndicators.append('<li data-target="#carousel-example-generic" data-slide-to="' + selector_number + '" class="active" />');
                    } else {
                        $selectorItem = $('<div class="selector item">');
                        $selectorIndicators.append('<li data-target="#carousel-example-generic" data-slide-to="' + selector_number + '" />');
                    }
                    $selectorItem.append($selectorRow);                        
                    $selectorRowDiv = $('<div class="selector_rowdiv">');
                    $selectorRow.append($selectorRowDiv);
                }
                $selectorItemDiv = $('<div class="selector_item">').attr('name',total_number);
                $img = $('<img>').attr({
                    'alt':$movie.find('title').text(),
                    'src':$movie.find('thumbnail').text(),
                    'data-target':'#videoCarousel',
                    'data-slide-to':total_number,
                    'data-toggle':'tooltip',
                    'data-original-title':$movie.find('title').text(),
                    'rel':'thumbnail'
                });
                $selectorItemDiv.append($img);
                item_number += 1;
                block_number += 1;
                if(block_number == 4) {
                  // 1段目が3つになったら2段目を作る
                  $selectorRowDiv = $('<div class="selector_rowdiv">');
                  $selectorRow.append($selectorRowDiv);
                }
                $selectorRowDiv.append($selectorItemDiv);
                if(item_number == 6) {
                  // 最大数（6）になったら今の行を追加してアイテム数をリセットする
                    $selectorRow.append($selectorRowDiv);
                    $selectorInner.append($selectorItem);
                    selector_number += 1;
                    item_number = 0;
                    block_number = 0;
                }                
            });
            if(item_number > 0) {
                $selectorInner.append($selectorItem);
            }
            $('img[rel=thumbnail]').tooltip();
            $('img[rel=thumbnail]').tooltip();
            // 初期表示時は最初のサムネイルをマークアップする
            $('div.selector_item:first > img').css({
                'background':'gray',
                'opacity':'0.5'
            });
        }
    });
}

function alertLoad(){
  console.log("load");
}


function selectionQuery() {
    url = '/sampler/keyword_selection';
    $.ajax({
        type: 'GET',
        url: url,
        datatype: 'xml',
        success: function(responseText,status) {
            var $query_counts = $(responseText).find("query-count");
            $('#keywordModal div.modal-body').children().remove();
            jQuery.each($query_counts,function() {
                $query_count = $(this);
                var $queryLink = $('<a></a>');
                var query = $query_count.find('query').text();
                $queryLink.attr('href','/sampler/search?keyword='+query);
                $queryLink.text(query);
                $('#keywordModal div.modal-body').append($queryLink);
            });
        }
    })
}

function carouselNext() {
    $('#videoCarousel').carousel('next');
}

(* XXX: some of the following code can be factored out *)

let content_type_css = [ "content-type", "text/css" ]

let linkbar = <:css<
  position: absolute;
  bottom: 0;
  right: 0;
  vertical-align: bottom;

  ul {
    list-style-type: none;
  }

  li {
    display: block;
    float: left;
  }

  li a {
    color: #222;
    display: block;
    float: left;
    font-size: 1.4em;
    height: 23px;
    padding: 8px 20px 0px 20px;
    text-decoration: none;
  }

  li a:hover {
    border-bottom: 5px solid #222;
    color: #222;
    height: 23px;
    padding: 8px 20px 0px 20px;
  }
    
  li a.current_page {
    border-bottom: 5px solid #222;
    color: #222;
    height: 23px;
    padding: 8px 20px 0px 20px;
  }
>>

let content = <:css<
  margin: 0 auto;
  position: relative;
  width: 960px;
  padding-top: 10px;
  padding-bottom: 10px;
  font-size: 1.3em;
  
  h2 {
    color: #222;
    font-family: "Helvetica Neue", "Helvetica", "Arial", sans-serif;
    font-size: 1.5em;
    font-weight: normal;
    margin: 0px 0px 0px 0px;
    padding: 8px 3px 0px 0px;
  }

  h3 {
    color: #222;
    font-family: "Helvetica Neue", "Helvetica", "Arial", sans-serif;
    font-size: 1.2em;
    font-weight: normal;
    margin: 0px 0px 0px 0px;
    padding: 5px 2px 0px 0px;
  }

  p {
    line-height: 130%;
    color: #222;
    padding: 5px 10px 3px 2px;
    text-align: justify;
  }

  ul {
    padding-left: 2em;
    list-style-type: square;
  }

  blockquote {
    background-color: #f2f2f2;
    border-left: 2px solid #aaa;
    font-size: 0.95em;
    padding: 11px 20px 10px 20px;
    margin: 10px 0px 8px 20px;
  }

  code {
    font-size: 90%;
  }

  p code {
    font-size: 110%;
  }

  blockquote p {
    font-size: 1.0em;
  }

  table {
    border: 0px solid #aaa;
    color: #222;
    margin: 10px 0px 10px 0px;
    min-width: 450px;
    text-align: left;
    width: 100%;
  }

  th {
    font-size: 1.3em;
    font-weight: bold;
    padding: 2px 0px 2px 5px;
  }

  tr.even_row {
    background-color: #e5e5e5;
  }

  td {
    font-size: 1.2em;
    padding: 2px 0px 2px 5px;
  }
   
  a {
    text-decoration: none;
    border-bottom: 1px dotted #ccc;
    color: #000077;
  }
    
  a:hover {
    border-bottom: 1px solid #aaa;
  }

  .aboutPerson {
    font-size: 0.8em;
  }

  $Pages.column_css$;
  $Blog.entries_css$
  $Wiki.page_css$;
>>

let wrapper = <:css<
  border-top: 1px solid #ccc;
  margin: 0 auto;
  width: 100%;

  #header {

    height: 77px;
    margin: 0 auto;
    position: relative;
    width: 960px;
    border-bottom: 1px solid #999999;

    #header_logo {
      float: left;
      position: relative;
      width: 465px;
      height: 77px;
      margin: 0px 0px 0px 0px;

      a#logo img {
        background: transparent;
        border: 0;
        margin: 0px 0px 0px 0px;
      }
    }

    #info_bar {
      height: 67px;
      width: 450px;
      margin: 0 auto;
      float: right;

      #linkbar { $linkbar$; }
    }
  }

  #content { $content$; }
>>
    
let footer = <:css<
  border-top: 1px solid #888;
  height: 30px;
  margin: 0 auto;
  padding: 5px 0px 0px 0px;
  position: relative;
  top: 10px;
  width: 960px;

  h4 {
    color: #222;
    float: left;
    font-size: 1.2em;
    font-weight: normal;
  }

  ul {
    float: right;
    list-style-type: none;
  }

  li {
    float: left;
  }

  a {
    color: #222;
    display: block;
    float: left;
    font-size: 1.2em;
    margin: 0px 0px 0px 20px;
    text-decoration: none;
  }

  a:hover {
    text-decoration: underline;
  }
>>

let date_css = <:css<
  .date {
    border: 1px solid #999;
    line-height: 1;
    width: 3em;
    position: relative;
    float: left;
    margin-right: 15px;
    text-align: center;
    .month {
      text-transform: uppercase;
      font-size: 0.9em;
      padding-top: 0.3em;
    }
    .day {
      font-size: 1.3em;
    }
    .year {
      background-color: #2358B8;
      color: #FFF;
      font-size: 0.9em;
      padding: 0.3em 0;
      margin-top: 0.3em;
    }
    .hour {
      display: none;
    }
    .min {
      display: none;
    }
  }
>>


let custom =Cow.Css.to_string <:css<
  $Cow.Css.reset_padding$;
  $date_css$;
  $Cow.Code.ocaml_css$;

  body {
    background-image: url('../graphics/cloud-bg.png');
    background-repeat: repeat-x;
    font: 65.0%/1.6 "helvetica neue", "helvetica", "arial", sans-serif;
  }

  a { outline: none; }

  #wrapper { $wrapper$; }

  #footer { $footer$; }

  .clear_div {
    clear: both;
  }

  .impl_red    { background-color: #FE9696; }
  .impl_orange { background-color: #FDC086; }
  .impl_green  { background-color: #B0ECB0; }
>>

let t = Lwt.return custom

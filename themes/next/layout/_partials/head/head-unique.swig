{{ open_graph() }}

{{ canonical() }}

{# Exports some front-matter variables to Front-End #}
<script id="page-configurations">
  // https://hexo.io/docs/variables.html
  CONFIG.page = {
    sidebar: {{ page.sidebar | json }},
    isHome : {{ is_home() }},
    isPost : {{ is_post() }},
    lang   : '{{ page.lang }}'
  };
  (function(){
          if('{{ page.password }}'){
              if (prompt('请输入文章密码') !== '{{ page.password }}'){
                  alert('密码错误！');
                  history.back();
              }
          }
      })();
</script>

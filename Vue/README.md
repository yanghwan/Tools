## Build

### Build Default
```bash
PS C:\yanghwan\vue-project> npm run build                                         

> vue-project@0.1.0 build
> vue-cli-service build

All browser targets in the browserslist configuration have supported ES module.
Therefore we don't build two separate bundles for differential loading.


/  Building for production...

 DONE  Compiled successfully in 17670ms                                                               오후 11:21:50

  File                                 Size                                 Gzipped

  dist\js\chunk-vendors.8c03739e.js    75.23 KiB                            28.05 KiB
  dist\js\app.bde487ab.js              13.06 KiB                            8.41 KiB
  dist\css\app.2cf79ad6.css            0.33 KiB                             0.23 KiB

  Images and other types of assets omitted.
  Build at: 2022-05-07T14:21:51.205Z - Hash: 1fe8bb7fd5f00a32 - Time: 17670ms

 DONE  Build complete. The dist directory is ready to be deployed.
 INFO  Check out deployment instructions at https://cli.vuejs.org/guide/deployment.html
       
PS C:\yanghwan\vue-project>

```

### vue-config.js File를 이용하여 Build folder 변경


```bash
# vue-config.js 내용

const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  outputDir: "C:/yanghwan/Test/src/main/resources/vue"  // 추가 // 추가 
//outputDir: 'C:/yanghwan/Test/src/main/resources/vue'  // 빌드할 폴더 경로
// outputDir: '../vue-project/dist' // vue-project 프로젝트 폴더안에 dist 폴더안에 빌드!
})

# 실행 결과.
```bash
C:\yanghwan\vue-project> npm run build                    

> vue-project@0.1.0 build
> vue-cli-service build

All browser targets in the browserslist configuration have supported ES module.
Therefore we don't build two separate bundles for differential loading.


|  Building for production...

 DONE  Compiled successfully in 10714ms                                                               오전 12:05:33

  File                                                       Size                      Gzipped

  ..\Test\src\main\resources\vue\js\chunk-vendors.8c03739    75.23 KiB                 28.05 KiB
  e.js
  ..\Test\src\main\resources\vue\js\app.bde487ab.js          13.06 KiB                 8.41 KiB
  ..\Test\src\main\resources\vue\css\app.2cf79ad6.css        0.33 KiB                  0.23 KiB

  Images and other types of assets omitted.
  Build at: 2022-05-07T15:05:33.700Z - Hash: 1fe8bb7fd5f00a32 - Time: 10714ms

 DONE  Build complete. The ..\Test\src\main\resources\vue directory is ready to be deployed.
 INFO  Check out deployment instructions at https://cli.vuejs.org/guide/deployment.html

```


```

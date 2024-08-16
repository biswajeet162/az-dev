trigger:
    - main  # Trigger the pipeline on changes to the main branch
    
    pool:
      vmImage: 'ubuntu-latest'  # Use the latest Ubuntu image
    
    variables:
      imageName: 'my-spring-boot-app'  # Name of your Docker image
    
    steps:
    - task: UseJavaVersion@1
      inputs:
        versionSpec: '17'  # Specify Java 17
        jdkArchitectureOption: 'x64'
        jdkSourceOption: 'PreInstalled'  # Use the pre-installed JDK
        jdkDestinationDirectory: '/usr/local/lib/jdk'
    
    - task: Maven@3
      inputs:
        mavenPomFile: 'pom.xml'
        options: '-B -ntp'
        goals: 'package'
        publishJUnitResults: true
        testResultsFiles: '**/surefire-reports/TEST-*.xml'
        javaHomeOption: 'JDKVersion'
        jdkVersionOption: '17'  # Use Java 17
        mavenVersionOption: 'Default'
        mavenAuthenticateFeed: false
        options: '-DskipTests'
    
    - task: Docker@2
      inputs:
        command: 'buildAndPush'
        repository: '$(imageName)'  # ACR repository name
        dockerfile: '**/Dockerfile'
        containerRegistry: '$(dockerRegistryServiceConnection)'  # Service connection name for ACR
        tags: |
          $(Build.BuildId)  # Tag the image with the build ID
    
    - script: |
        echo "Deploying to Azure Container Registry"
      displayName: 'Deploying to Azure Container Registry'
    
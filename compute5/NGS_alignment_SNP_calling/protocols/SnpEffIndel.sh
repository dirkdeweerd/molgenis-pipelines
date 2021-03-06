#MOLGENIS walltime=35:59:00 mem=4gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffCallsHtml
#string snpEffCallsVcf
#string snpEffGenesTxt
#string inputVcf
#string tmpDataDir
#string project
#string GATKVersion
#string SnpEffVersion
#string JavaVersion


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "snpEffCallsHtml: ${snpEffCallsHtml}"
echo "snpEffCallsVcf: ${snpEffCallsVcf}"
echo "snpEffGenesTxt: ${snpEffGenesTxt}"

sleep 10

makeTmpDir ${snpEffCallsHtml}
tmpSnpEffCallsHtml=${MC_tmpFile}

makeTmpDir ${snpEffCallsVcf}
tmpSnpEffCallsVcf=${MC_tmpFile}

makeTmpDir ${snpEffGenesTxt}
tmpSnpEffGenesTxt=${MC_tmpFile}

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load GATK module
${stage} jdk/${JavaVersion}
${stage} GATK/${GATKVersion}
${stage} snpEff/${SnpEffVersion}
${checkStage}

#Run snpEff
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/snpEff.jar \
eff \
-v \
-c $SNPEFF_HOME/snpEff.config \
-i vcf \
-o gatk \
GRCh37.69 \
-stats ${tmpSnpEffCallsHtml} \
${inputVcf} \
> ${tmpSnpEffCallsVcf}

#${intermediateDir}${project}.indels.calls.mergedAllVcf.vcf \

    mv ${tmpSnpEffCallsHtml} ${snpEffCallsHtml}
    mv ${tmpSnpEffCallsVcf} ${snpEffCallsVcf}
    mv ${tmpSnpEffGenesTxt} ${snpEffGenesTxt}

#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string baitChrBed
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string sampleChrVariantCalls
#string sampleChrVariantCallsIdx
#string externalSampleID
#string tmpDataDir

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "baitChrBed: ${baitChrBed}"
echo "dbSNP137Vcf: ${dbSNP137Vcf}"
echo "dbSNP137VcfIdx: ${dbSNP137VcfIdx}"


sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}


INPUTS=()

#Get BQSR BAM, idx file and resources
getFile indexFile
getFile dbSNP137Vcf
getFile dbSNP137VcfIdx


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

makeTmpDir ${sampleChrVariantCalls}
tmpSampleChrVariantCalls=${MC_tmpFile}

makeTmpDir ${sampleChrVariantCallsIdx}
tmpSampleChrVariantCallsIdx=${MC_tmpFile}

#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T HaplotypeCaller \
-R ${indexFile} \
-I ${intermediateDir}/${externalSampleID}.merged.dedup.realigned.bqsr.bam \
--dbsnp ${dbSNP137Vcf} \
--genotyping_mode DISCOVERY \
-stand_emit_conf 10 \
-stand_call_conf 30 \
-o ${tmpSampleChrVariantCalls} \
-L ${baitChrBed} \
-nct 16

echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
mv ${tmpSampleChrVariantCalls} ${sampleChrVariantCalls}
mv ${tmpSampleChrVariantCallsIdx} ${sampleChrVariantCallsIdx}


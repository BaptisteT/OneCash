#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "ApplePayStubs/ApplePayStubs/STPTestPaymentSummaryViewController.xib"
  install_resource "DateTools/DateTools/DateTools.bundle"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowLeft.imageset/MPArrowLeft.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowLeft.imageset/MPArrowLeft@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowRight.imageset/MPArrowRight.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowRight.imageset/MPArrowRight@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCheckmark.imageset/MPCheckmark.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCheckmark.imageset/MPCheckmark@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCloseBtn.imageset/MPCloseBtn.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCloseBtn.imageset/MPCloseBtn@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPDismissKeyboard.imageset/MPDismissKeyboard.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPDismissKeyboard.imageset/MPDismissKeyboard@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPLogo.imageset/MPLogo.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPLogo.imageset/MPLogo@2x.png"
  install_resource "Mixpanel/Mixpanel/MPNotification.storyboard"
  install_resource "Mixpanel/Mixpanel/MPSurvey.storyboard"
  install_resource "Parse/Parse/Resources/en.lproj"
  install_resource "ParseTwitterUtils/Resources/en.lproj"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@3x.png"
  install_resource "Stripe/Stripe/Resources/Images"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "ApplePayStubs/ApplePayStubs/STPTestPaymentSummaryViewController.xib"
  install_resource "DateTools/DateTools/DateTools.bundle"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowLeft.imageset/MPArrowLeft.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowLeft.imageset/MPArrowLeft@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowRight.imageset/MPArrowRight.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPArrowRight.imageset/MPArrowRight@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCheckmark.imageset/MPCheckmark.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCheckmark.imageset/MPCheckmark@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCloseBtn.imageset/MPCloseBtn.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPCloseBtn.imageset/MPCloseBtn@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPDismissKeyboard.imageset/MPDismissKeyboard.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPDismissKeyboard.imageset/MPDismissKeyboard@2x.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPLogo.imageset/MPLogo.png"
  install_resource "Mixpanel/Mixpanel/Media.xcassets/MPLogo.imageset/MPLogo@2x.png"
  install_resource "Mixpanel/Mixpanel/MPNotification.storyboard"
  install_resource "Mixpanel/Mixpanel/MPSurvey.storyboard"
  install_resource "Parse/Parse/Resources/en.lproj"
  install_resource "ParseTwitterUtils/Resources/en.lproj"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@3x.png"
  install_resource "Stripe/Stripe/Resources/Images"
fi

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
